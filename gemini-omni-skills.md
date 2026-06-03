# Gemini Omni — MuAPI Skills Reference

Scraped from [muapi.ai/docs](https://muapi.ai/docs/introduction) on 2026-06-03.

**Gemini Omni** is Google's natively multimodal **any-to-any** model (unveiled at I/O 2026,
May 19 2026). On MuAPI it is exposed as the **Gemini Omni Flash** family — text, image,
audio, and video reasoned together in a single forward pass, with **synchronized audio**
(dialogue, ambient sound, music) generated alongside the visuals. No chained pipelines,
no cross-model drift.

The family has **5 skills / endpoints**:

| # | Skill | Type | Endpoint | Price |
|---|-------|------|----------|-------|
| 1 | Gemini Omni Text-to-Video | T2V | `/api/v1/gemini-omni-text-to-video` | from $1.50 (4K up to $2.70/$3.00) |
| 2 | Gemini Omni Image-to-Video | I2V | `/api/v1/gemini-omni-image-to-video` | from $1.50 (4K up to $3.00) |
| 3 | Gemini Omni Video Edit | V2V | `/api/v1/gemini-omni-video-edit` | $2.40 (720p/1080p) · $3.60 (4K) |
| 4 | Gemini Omni Audio (voice profile) | profile | (voice profile creation) | Free |
| 5 | Gemini Omni Character (character profile) | profile | (character creation) | Free |

> Availability: Gemini Omni is on the **Pro** and **Business** plans. Supports **16:9** and
> **9:16** aspect ratios. Durations: **4, 6, 8, 10 s**. Resolutions: **720p, 1080p, 4K**
> (720p and 1080p are priced the same; 4K costs more). Synchronized audio is included at
> no extra charge.

---

## Authentication & request pattern

All MuAPI calls use the same **submit-then-poll** pattern.

- **Header:** `x-api-key: {MUAPIAPP_API_KEY}` + `Content-Type: application/json`
- **Base URL:** `https://api.muapi.ai`  (the site also accepts `https://muapi.ai`)
- **Submit:** `POST /api/v1/<endpoint>` → returns a `request_id`
- **Poll:** `GET /api/v1/predictions/{request_id}/result` until `status` is `completed`
- Get a key at [muapi.ai/dashboard](https://muapi.ai/dashboard). Use a **Sandbox** key during
  development — it returns mock data instantly and consumes no credits.

```bash
curl --location --request POST 'https://api.muapi.ai/api/v1/gemini-omni-text-to-video' \
  --header "Content-Type: application/json" \
  --header "x-api-key: $MUAPIAPP_API_KEY" \
  --data-raw '{"prompt": "A bustling Tokyo night market, neon on wet pavement, ambient chatter."}'
```

### Shared video parameters (T2V / I2V / V2V)

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `duration` | enum: 4, 6, 8, 10 | Video length in seconds | `8` |
| `resolution` | enum: 720p, 1080p, 4k | Output resolution (720p/1080p same price; 4K costs more) | `1080p` |
| `aspect_ratio` | enum: 16:9, 9:16 | Output aspect ratio | `16:9` |
| `audio_ids` | array (≤3) | Voice profile IDs from Gemini Omni Audio | – |
| `character_ids` | array (≤3) | Character IDs from Gemini Omni Character | – |
| `seed` | int (0–2147483647) | Random seed for reproducibility | `0` |

> **Slot budget:** generations have **7 image slots** total. A source video uses **2**,
> each reference image uses **1**, and each `character_id` uses **1**.

---

## 1. Gemini Omni Text-to-Video (T2V)

`POST /api/v1/gemini-omni-text-to-video`

Generate cinematic video with synchronized dialogue, ambient audio, and music from a single
text prompt — all in one forward pass. Up to 4K.

**Parameters**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt` | string | ✅ | Text description of the desired video. Supports rich multimodal prompts: scene composition, camera direction, dialogue, ambient audio cues. |
| `duration` | enum (4/6/8/10) | | Seconds. Default `8`. |
| `resolution` | enum (720p/1080p/4k) | | Default `1080p`. |
| `aspect_ratio` | enum (16:9/9:16) | | Default `16:9`. |
| `audio_ids` | array (≤3) | | Voice profile IDs. |
| `character_ids` | array (≤3) | | Character IDs. |
| `seed` | int | | Default `0`. |

**Tips:** describe sound explicitly (`soft piano underscore`, `wind through trees`); wrap
spoken dialogue in quotes and describe the speaker; specify camera moves (`slow dolly in`,
`handheld tracking shot`, `crane reveal`).

**Use cases:** film & advertising, social content (TikTok/Reels/Shorts), storyboarding,
localization (regenerate dialogue in a new language), education & explainers.

---

## 2. Gemini Omni Image-to-Video (I2V)

`POST /api/v1/gemini-omni-image-to-video`

Animate **1–5 reference images** with a text prompt. Preserves subject identity across
frames and generates synchronized audio natively. Up to 4K.

**Parameters** — shared video params plus:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt` | string | ✅ | Desired motion and scene; supports camera direction, dialogue, ambient audio cues. |
| `image_urls` | array (1–5) | ✅ | Reference images, max 20 MB each. Each image uses 1 slot. |

**Use cases:** product animation, character animation, storyboarding from concept art,
turning stills into vertical/widescreen social clips.

---

## 3. Gemini Omni Video Edit (V2V)

`POST /api/v1/gemini-omni-video-edit`

Source-driven editing: restyle, relight, swap subjects, or rewrite dialogue while preserving
original motion and timing. Flat $2.40 (720p/1080p) / $3.60 (4K) regardless of duration.

**Parameters** — shared video params plus:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt` (edit prompt) | string | ✅ | Describe the edit to apply (e.g. "restyle to watercolor", "change the season"). |
| `video_url` (source video) | string | optional* | Source clip, max 100 MB, max 30 s. *Optional if `image_urls` are provided. Uses 2 slots. |
| `image_urls` | array (≤5) | | Reference images, max 20 MB each. |
| `trim_start` | number (≥0) | | Start of clip window to edit, seconds. Default `0`. |
| `trim_end` | number | | End of clip window; must be within 10 s of `trim_start`. Default `10`. |

**Tips:** anchor what should *not* change (`keep the original framing`, `preserve subject
identity`, `maintain camera path`); name the target style explicitly (`1980s VHS`, `oil
painting`, `claymation`). To edit only audio (e.g. swap dialogue), disable `preserve_audio`
and target only the audio in the prompt.

**Use cases:** restyle & relight, localization (rewrite dialogue, preserve lip motion),
continuity fixes (wardrobe/props/background), creative iteration, content adaptation.

---

## 4. Gemini Omni Audio — Voice Profile (Free)

Create a named, reusable **voice profile** from one of 30 preset voices. Returns an
`audio_id` (a voice-config token, **not** a playable file) that you pass in the `audio_ids`
field (up to 3) of any video endpoint.

**Parameters**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `base_voice` | enum (30 options) | ✅ | Preset base voice (or auto-detect). |
| `profile_name` | string (≤210 chars) | ✅ | Name for the profile (returned with the ID). |
| `voice_description` | string (≤20,000 chars) | | Timbre, style, emotion, accent, pacing. |
| `example_dialogue` | string (≤120 chars) | | Sample sentence to anchor the voice style. |

**30 preset base voices:** achernar, achird, algenib, algieba, alnilam, aoede, autonoe,
callirrhoe, charon, despina, enceladus, erinome, fenrir, gacrux, iapetus, korelaomedeia
(korel/aomedeia), leda, orus, puck, pulcherrima, rasalgethi, sadachbia, sadaltager, schedar,
sulafat, umbriel, vindemiatrix, zephyr, zubenelgenubi.

**Flow:** pick a base voice → name the profile → (optional) describe voice → (optional) add
example dialogue → submit → store the returned `audio_id` → pass it in `audio_ids` on T2V /
I2V / V2V calls.

---

## 5. Gemini Omni Character — Character Profile (Free)

Create a reusable **character** from exactly **1 reference image** + a text description.
Optionally attach voice profiles. Returns a `character_id` (plus a generated character image)
that you pass in the `character_ids` field (up to 3) of any video endpoint.

**Parameters**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `descriptions` (character description) | string | ✅ | Appearance, identity, style, personality. |
| `images_list` (reference image) | array (exactly 1) | ✅ | One image, max 20 MB, publicly accessible URL. |
| `character_name` | string | | Optional display name. |
| `audio_ids` (voice profile IDs) | array (≤20) | | Voice profile IDs from Gemini Omni Audio to associate. |

**Output:** `character_id`, `character_name`, and an image URL in `outputs`.

**Flow:** provide reference image → describe character → (optional) name → (optional) attach
voice profile `audio_ids` → submit → store `character_id` → pass it in `character_ids` on
video calls for consistent character-driven generation.

---

## Putting it together — character-consistent workflow

1. **Create a voice** → `gemini-omni-audio` → get `audio_id`.
2. **Create a character** → `gemini-omni-character` (reference image + description, attach the
   `audio_id`) → get `character_id`.
3. **Generate video** → `gemini-omni-text-to-video` / `-image-to-video` / `-video-edit`,
   passing `character_ids: [character_id]` and/or `audio_ids: [audio_id]`.
4. **Poll** `GET /api/v1/predictions/{request_id}/result` until `completed`.

---

## Bonus: MuAPI Agent Skills (shell scripts for coding agents)

Beyond the Omni model endpoints, MuAPI ships generic **Agent Skills** — schema-driven shell
scripts for Claude Code, Cursor, Gemini CLI, and other MCP tools. They auto-resolve the
latest models/endpoints/params from `schema_data.json`, support local-file upload to the CDN,
and have a `--view` flag to open generated media.

```bash
# Install
npx skills add SamurAIGPT/Generative-Media-Skills --all
npx skills add SamurAIGPT/Generative-Media-Skills --list

# Configure key
bash core/platform/setup.sh --add-key "YOUR_MUAPI_KEY"

# Generate video (Gemini Omni is reachable via --model once live)
bash core/media/generate-video.sh -p "A city skyline day to night" -m gemini-omni-text-to-video --view
```

Core scripts: `core/media/generate-image.sh`, `generate-video.sh`, `image-to-video.sh`,
`create-music.sh`, `upload.sh`; `core/edit/edit-image.sh`, `enhance-image.sh`, `lipsync.sh`,
`video-effects.sh`; `core/platform/setup.sh`, `check-result.sh`. Common flags: `--prompt/-p`,
`--model/-m`, `--async`, `--view`, `--file`, `--json`, `--timeout N`, `--help/-h`.

Natural-language workflow recipes are also discoverable via a public API:
`GET https://api.muapi.ai/api/v1/agent-skills` (list) and
`GET https://api.muapi.ai/api/v1/agent-skills/{name}` (full markdown).

---

### Sources

- https://muapi.ai/gemini-omni
- https://muapi.ai/playground/gemini-omni-text-to-video
- https://muapi.ai/playground/gemini-omni-image-to-video
- https://muapi.ai/playground/gemini-omni-video-edit
- https://muapi.ai/playground/gemini-omni-audio
- https://muapi.ai/playground/gemini-omni-character
- https://muapi.ai/docs/agent-skills
- https://muapi.ai/docs/authentication
