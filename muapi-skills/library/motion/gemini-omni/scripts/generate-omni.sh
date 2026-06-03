#!/bin/bash
# muapi.ai — Gemini Omni (any-to-any multimodal) skill
# Modes: t2v | i2v | video-edit | audio (voice profile) | character (character profile)
# Usage: ./generate-omni.sh --mode t2v --prompt "..." [options]

set -e

MUAPI_BASE="https://api.muapi.ai/api/v1"

# ---- Defaults ----
MODE="t2v"
PROMPT=""
RESOLUTION="1080p"     # 720p | 1080p | 4k
ASPECT_RATIO="16:9"    # 16:9 | 9:16
DURATION=8             # 4 | 6 | 8 | 10
SEED=""

# Reference inputs (repeatable)
IMAGE_URLS=()
IMAGE_FILES=()
AUDIO_IDS=()
CHARACTER_IDS=()

# Video-edit inputs
VIDEO_URL=""
VIDEO_FILE=""
TRIM_START=""
TRIM_END=""

# Audio voice-profile inputs
BASE_VOICE=""
PROFILE_NAME=""
VOICE_DESCRIPTION=""
EXAMPLE_DIALOGUE=""

# Character-profile inputs
CHARACTER_NAME=""

# Behaviour
ASYNC=false
VIEW=false
JSON_ONLY=false
MAX_WAIT=600
POLL_INTERVAL=5
ACTION="generate"
REQUEST_ID=""

usage() {
    cat >&2 <<'EOF'
Gemini Omni — any-to-any multimodal video (muapi.ai)

Usage: ./generate-omni.sh --mode MODE [options]

Modes:
  t2v          Text-to-Video           (--prompt)
  i2v          Image-to-Video          (--prompt + 1-5 --image/--image-url)
  video-edit   Source-driven edit      (--prompt + --video/--video-url)
  audio        Create a voice profile  (--base-voice --name)        -> audio_id (free)
  character    Create a character      (--desc + 1 --image)         -> character_id (free)

Common options:
  --prompt, -p TEXT        Prompt / edit instruction (t2v, i2v, video-edit)
  --resolution R           720p | 1080p | 4k                 (default: 1080p)
  --aspect-ratio A         16:9 | 9:16                       (default: 16:9)
  --duration N             4 | 6 | 8 | 10 seconds            (default: 8)
  --seed N                 Fix seed (0-2147483647)
  --image-url URL          Reference image URL  (repeatable, 1-5)
  --image PATH             Local reference image (auto-uploads, repeatable)
  --audio-id ID            Voice profile ID from `--mode audio` (repeatable, max 3)
  --character-id ID        Character ID from `--mode character` (repeatable, max 3)

Video-edit options:
  --video-url URL          Source clip URL (max 100MB / 30s)
  --video PATH             Local source clip (auto-uploads)
  --trim-start N           Edit window start (seconds, >=0)
  --trim-end N             Edit window end (<= trim-start + 10s)

Audio (voice profile) options:
  --base-voice NAME        One of 30 presets (e.g. zephyr, charon, achernar)
  --name TEXT              Profile name (required)
  --voice-desc TEXT        Timbre / style / emotion description
  --example TEXT           Short sample sentence (<=120 chars)

Character (profile) options:
  --desc TEXT              Character description (required)
  --image / --image-url    Exactly 1 reference image (required)
  --name TEXT              Character display name
  --audio-id ID            Voice profile(s) to attach (repeatable)

Behaviour:
  --async                  Return request_id immediately (no polling)
  --view                   Download + open the result (macOS)
  --json                   Raw JSON output only
  --timeout N              Max wait in seconds (default: 600)
  --result ID              Fetch the result of a prior request_id
  --add-key [KEY]          Save MUAPI_KEY to .env
  --help, -h               Show this help
EOF
}

# ---- --add-key handling ----
for arg in "$@"; do
    if [ "$arg" = "--add-key" ]; then
        shift
        KEY_VALUE=""
        if [[ -n "$1" && ! "$1" =~ ^-- ]]; then KEY_VALUE="$1"; fi
        if [ -z "$KEY_VALUE" ]; then echo "Enter your muapi.ai API key:" >&2; read -r KEY_VALUE; fi
        if [ -n "$KEY_VALUE" ]; then
            grep -v "^MUAPI_KEY=" .env > .env.tmp 2>/dev/null || true
            mv .env.tmp .env 2>/dev/null || true
            echo "MUAPI_KEY=$KEY_VALUE" >> .env
            echo "MUAPI_KEY saved to .env" >&2
        fi
        exit 0
    fi
done

# ---- Parse arguments ----
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode) MODE="$2"; shift 2 ;;
        --prompt|-p) PROMPT="$2"; shift 2 ;;
        --resolution) RESOLUTION="$2"; shift 2 ;;
        --aspect-ratio) ASPECT_RATIO="$2"; shift 2 ;;
        --duration) DURATION="$2"; shift 2 ;;
        --seed) SEED="$2"; shift 2 ;;
        --image-url) IMAGE_URLS+=("$2"); shift 2 ;;
        --image|--file) IMAGE_FILES+=("$2"); shift 2 ;;
        --audio-id) AUDIO_IDS+=("$2"); shift 2 ;;
        --character-id) CHARACTER_IDS+=("$2"); shift 2 ;;
        --video-url) VIDEO_URL="$2"; shift 2 ;;
        --video) VIDEO_FILE="$2"; shift 2 ;;
        --trim-start) TRIM_START="$2"; shift 2 ;;
        --trim-end) TRIM_END="$2"; shift 2 ;;
        --base-voice) BASE_VOICE="$2"; shift 2 ;;
        --name) PROFILE_NAME="$2"; CHARACTER_NAME="$2"; shift 2 ;;
        --voice-desc) VOICE_DESCRIPTION="$2"; shift 2 ;;
        --example) EXAMPLE_DIALOGUE="$2"; shift 2 ;;
        --desc) PROMPT="$2"; shift 2 ;;
        --async) ASYNC=true; shift ;;
        --view) VIEW=true; shift ;;
        --json) JSON_ONLY=true; shift ;;
        --timeout) MAX_WAIT="$2"; shift 2 ;;
        --status|--result) ACTION="result"; REQUEST_ID="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) shift ;;
    esac
done

# ---- Requirements ----
command -v jq >/dev/null || { echo "Error: jq is required" >&2; exit 1; }
[ -f ".env" ] && { source .env 2>/dev/null || true; }
if [ -z "$MUAPI_KEY" ]; then echo "Error: MUAPI_KEY not set (run: $0 --add-key)" >&2; exit 1; fi
HEADERS=(-H "x-api-key: $MUAPI_KEY" -H "Content-Type: application/json")

log() { [ "$JSON_ONLY" = false ] && echo "$@" >&2; return 0; }

# ---- Fetch a prior result ----
if [ "$ACTION" = "result" ]; then
    [ -z "$REQUEST_ID" ] && { echo "Error: Request ID required" >&2; exit 1; }
    curl -s -X GET "${MUAPI_BASE}/predictions/${REQUEST_ID}/result" "${HEADERS[@]}"
    exit 0
fi

# ---- Helpers ----
upload_file() {
    local FPATH="$1"
    [ -f "$FPATH" ] || { echo "Error: File not found: $FPATH" >&2; exit 1; }
    log "Uploading $(basename "$FPATH")..."
    local RESP URL
    RESP=$(curl -s -X POST "${MUAPI_BASE}/upload_file" -H "x-api-key: $MUAPI_KEY" -F "file=@${FPATH}")
    URL=$(echo "$RESP" | jq -r '.url // empty')
    [ -z "$URL" ] && { echo "Error: upload failed: $(echo "$RESP" | jq -r '.error // .detail // "unknown"')" >&2; exit 1; }
    echo "$URL"
}

to_json_array() {  # turns bash args into a JSON string array
    if [ "$#" -eq 0 ]; then echo "[]"; else printf '%s\n' "$@" | jq -R . | jq -s .; fi
}

# Auto-upload any local images / video
for f in "${IMAGE_FILES[@]}"; do IMAGE_URLS+=("$(upload_file "$f")"); done
if [ -n "$VIDEO_FILE" ]; then VIDEO_URL="$(upload_file "$VIDEO_FILE")"; fi

AUDIO_JSON=$(to_json_array "${AUDIO_IDS[@]}")
CHAR_JSON=$(to_json_array "${CHARACTER_IDS[@]}")
IMAGES_JSON=$(to_json_array "${IMAGE_URLS[@]}")

# ---- Build endpoint + payload per mode ----
case "$MODE" in
    t2v)
        [ -z "$PROMPT" ] && { echo "Error: --prompt required for t2v" >&2; exit 1; }
        ENDPOINT="gemini-omni-text-to-video"
        PAYLOAD=$(jq -n --arg prompt "$PROMPT" --arg resolution "$RESOLUTION" \
            --arg aspect_ratio "$ASPECT_RATIO" --argjson duration "$DURATION" \
            --argjson audio_ids "$AUDIO_JSON" --argjson character_ids "$CHAR_JSON" \
            '{prompt:$prompt, duration:$duration, resolution:$resolution, aspect_ratio:$aspect_ratio}
             + (if ($audio_ids|length)>0 then {audio_ids:$audio_ids} else {} end)
             + (if ($character_ids|length)>0 then {character_ids:$character_ids} else {} end)')
        ;;
    i2v)
        [ -z "$PROMPT" ] && { echo "Error: --prompt required for i2v" >&2; exit 1; }
        [ "$(echo "$IMAGES_JSON" | jq 'length')" -eq 0 ] && { echo "Error: i2v needs 1-5 --image/--image-url" >&2; exit 1; }
        ENDPOINT="gemini-omni-image-to-video"
        PAYLOAD=$(jq -n --arg prompt "$PROMPT" --arg resolution "$RESOLUTION" \
            --arg aspect_ratio "$ASPECT_RATIO" --argjson duration "$DURATION" \
            --argjson image_urls "$IMAGES_JSON" \
            --argjson audio_ids "$AUDIO_JSON" --argjson character_ids "$CHAR_JSON" \
            '{prompt:$prompt, image_urls:$image_urls, duration:$duration, resolution:$resolution, aspect_ratio:$aspect_ratio}
             + (if ($audio_ids|length)>0 then {audio_ids:$audio_ids} else {} end)
             + (if ($character_ids|length)>0 then {character_ids:$character_ids} else {} end)')
        ;;
    video-edit|v2v)
        [ -z "$PROMPT" ] && { echo "Error: --prompt (edit instruction) required for video-edit" >&2; exit 1; }
        [ -z "$VIDEO_URL" ] && [ "$(echo "$IMAGES_JSON" | jq 'length')" -eq 0 ] && \
            { echo "Error: video-edit needs --video/--video-url (or --image)" >&2; exit 1; }
        ENDPOINT="gemini-omni-video-edit"
        PAYLOAD=$(jq -n --arg prompt "$PROMPT" --arg resolution "$RESOLUTION" \
            --arg aspect_ratio "$ASPECT_RATIO" --argjson duration "$DURATION" \
            --arg video_url "$VIDEO_URL" --argjson image_urls "$IMAGES_JSON" \
            --argjson audio_ids "$AUDIO_JSON" --argjson character_ids "$CHAR_JSON" \
            '{prompt:$prompt, duration:$duration, resolution:$resolution, aspect_ratio:$aspect_ratio}
             + (if ($video_url|length)>0 then {video_url:$video_url} else {} end)
             + (if ($image_urls|length)>0 then {image_urls:$image_urls} else {} end)
             + (if ($audio_ids|length)>0 then {audio_ids:$audio_ids} else {} end)
             + (if ($character_ids|length)>0 then {character_ids:$character_ids} else {} end)')
        if [ -n "$TRIM_START" ]; then PAYLOAD=$(echo "$PAYLOAD" | jq --argjson v "$TRIM_START" '. + {trim_start:$v}'); fi
        if [ -n "$TRIM_END" ]; then PAYLOAD=$(echo "$PAYLOAD" | jq --argjson v "$TRIM_END" '. + {trim_end:$v}'); fi
        ;;
    audio)
        [ -z "$BASE_VOICE" ] && { echo "Error: --base-voice required for audio" >&2; exit 1; }
        [ -z "$PROFILE_NAME" ] && { echo "Error: --name required for audio" >&2; exit 1; }
        ENDPOINT="gemini-omni-audio"
        PAYLOAD=$(jq -n --arg base_voice "$BASE_VOICE" --arg profile_name "$PROFILE_NAME" \
            --arg voice_description "$VOICE_DESCRIPTION" --arg example_dialogue "$EXAMPLE_DIALOGUE" \
            '{base_voice:$base_voice, profile_name:$profile_name}
             + (if ($voice_description|length)>0 then {voice_description:$voice_description} else {} end)
             + (if ($example_dialogue|length)>0 then {example_dialogue:$example_dialogue} else {} end)')
        ;;
    character)
        [ -z "$PROMPT" ] && { echo "Error: --desc required for character" >&2; exit 1; }
        [ "$(echo "$IMAGES_JSON" | jq 'length')" -ne 1 ] && { echo "Error: character needs exactly 1 --image/--image-url" >&2; exit 1; }
        ENDPOINT="gemini-omni-character"
        PAYLOAD=$(jq -n --arg descriptions "$PROMPT" --argjson images_list "$IMAGES_JSON" \
            --arg character_name "$CHARACTER_NAME" --argjson audio_ids "$AUDIO_JSON" \
            '{descriptions:$descriptions, images_list:$images_list}
             + (if ($character_name|length)>0 then {character_name:$character_name} else {} end)
             + (if ($audio_ids|length)>0 then {audio_ids:$audio_ids} else {} end)')
        ;;
    *)
        echo "Error: unknown --mode '$MODE' (t2v | i2v | video-edit | audio | character)" >&2; exit 1 ;;
esac

# Append seed where relevant
if [ -n "$SEED" ] && [[ "$MODE" =~ ^(t2v|i2v|video-edit|v2v)$ ]]; then
    PAYLOAD=$(echo "$PAYLOAD" | jq --argjson v "$SEED" '. + {seed:$v}')
fi

# ---- Submit ----
log "Submitting to $ENDPOINT..."
SUBMIT=$(curl -s -X POST "${MUAPI_BASE}/${ENDPOINT}" "${HEADERS[@]}" -d "$PAYLOAD")

if echo "$SUBMIT" | jq -e 'has("error") or has("detail")' >/dev/null 2>&1; then
    echo "Error: $(echo "$SUBMIT" | jq -r '.error // .detail')" >&2; exit 1
fi

# Some endpoints (audio/character) may return IDs synchronously
DIRECT_ID=$(echo "$SUBMIT" | jq -r '.audio_id // .character_id // empty')
if [ -n "$DIRECT_ID" ]; then
    log "Done. ID: $DIRECT_ID"
    echo "$SUBMIT"; exit 0
fi

REQUEST_ID=$(echo "$SUBMIT" | jq -r '.request_id // empty')
[ -z "$REQUEST_ID" ] && { echo "Error: no request_id in response:" >&2; echo "$SUBMIT" >&2; exit 1; }
log "Request ID: $REQUEST_ID"

if [ "$ASYNC" = true ]; then echo "$SUBMIT"; exit 0; fi

# ---- Poll ----
log "Waiting for completion..."
ELAPSED=0; LAST=""
while [ $ELAPSED -lt $MAX_WAIT ]; do
    sleep $POLL_INTERVAL; ELAPSED=$((ELAPSED + POLL_INTERVAL))
    RESULT=$(curl -s -X GET "${MUAPI_BASE}/predictions/${REQUEST_ID}/result" "${HEADERS[@]}")
    STATUS=$(echo "$RESULT" | jq -r '.status // empty')
    [ "$STATUS" != "$LAST" ] && { log "Status: $STATUS (${ELAPSED}s)"; LAST="$STATUS"; }
    case "$STATUS" in
        completed)
            URL=$(echo "$RESULT" | jq -r '(.outputs[0] // .audio_id // .character_id) // empty')
            log "Success! $URL"
            if [ "$VIEW" = true ] && [[ "$URL" == http* ]]; then
                EXT="${URL##*.}"; [[ "$EXT" == http* || -z "$EXT" ]] && EXT="mp4"
                OUT_DIR="$(dirname "$0")/../../../../media_outputs"; mkdir -p "$OUT_DIR"
                TMP="$OUT_DIR/omni_$(date +%s).$EXT"
                log "Downloading to $TMP..."; curl -s -o "$TMP" "$URL"
                [[ "$OSTYPE" == "darwin"* ]] && open "$TMP" 2>/dev/null || true
            fi
            echo "$RESULT"; exit 0 ;;
        failed)
            echo "Error: generation failed: $(echo "$RESULT" | jq -r '.output.error // .error // "unknown"')" >&2
            echo "$RESULT"; exit 1 ;;
    esac
done
echo "Error: timeout after ${MAX_WAIT}s — check later: $0 --result \"$REQUEST_ID\"" >&2
exit 1
