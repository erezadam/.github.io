---
slug: muapi-gemini-omni
name: muapi-gemini-omni
version: "0.1.0"
description: Expert skill for Gemini Omni (Google) — natively multimodal any-to-any video on muapi.ai. Text-to-video, image-to-video, and video-edit with synchronized audio in one forward pass, plus reusable voice profiles and character profiles for consistent character-driven generation.
acceptLicenseTerms: true
---

# 🎛️ Gemini Omni — Any-to-Any Multimodal Video

**One model, one forward pass: text, image, audio, and video reasoned together.**
Gemini Omni (Google, I/O 2026) generates high-fidelity video with **natively synchronized
audio** — dialogue, ambient sound, and music — without chaining specialized models. This
skill wraps all five Gemini Omni endpoints behind a single `generate-omni.sh` dispatcher.

> **Audio is generated natively.** Every t2v/i2v/video-edit call produces synchronized sound.
> Describe sound in your prompt (music, SFX, ambience, dialogue) — silence yields random audio.

---

## 🎬 Modes

| Mode | Flag | Endpoint | Price | Output |
|:---|:---|:---|:---|:---|
| **Text-to-Video** | `--mode t2v` | `gemini-omni-text-to-video` | from $1.50 | video + audio |
| **Image-to-Video** | `--mode i2v` | `gemini-omni-image-to-video` | from $1.50 | video + audio |
| **Video Edit** | `--mode video-edit` | `gemini-omni-video-edit` | $2.40 / $3.60 (4K) | video + audio |
| **Voice Profile** | `--mode audio` | `gemini-omni-audio` | **Free** | `audio_id` |
| **Character Profile** | `--mode character` | `gemini-omni-character` | **Free** | `character_id` |

---

## 📐 Parameters

| Param | Flag | Values | Default | Applies to |
|:---|:---|:---|:---|:---|
| Resolution | `--resolution` | `720p` · `1080p` · `4k` | `1080p` | t2v, i2v, video-edit |
| Aspect ratio | `--aspect-ratio` | `16:9` · `9:16` | `16:9` | t2v, i2v, video-edit |
| Duration | `--duration` | `4` · `6` · `8` · `10` | `8` | t2v, i2v, video-edit |
| Seed | `--seed` | `0`–`2147483647` | random | t2v, i2v, video-edit |
| Voice profiles | `--audio-id` | up to **3** | — | t2v, i2v, video-edit, character |
| Character profiles | `--character-id` | up to **3** | — | t2v, i2v, video-edit |

> **Slot budget (i2v / video-edit):** 7 image slots total. A source video uses **2**, each
> reference image uses **1**, each `--character-id` uses **1**. 720p and 1080p cost the same.

---

## 📥 Inputs

| Mode | Required | Optional |
|:---|:---|:---|
| `t2v` | `--prompt` | `--audio-id`, `--character-id`, `--seed` |
| `i2v` | `--prompt` + 1–5 `--image`/`--image-url` | `--audio-id`, `--character-id`, `--seed` |
| `video-edit` | `--prompt` + `--video`/`--video-url` | `--image` (refs), `--trim-start/-end`, ids, `--seed` |
| `audio` | `--base-voice` + `--name` | `--voice-desc`, `--example` |
| `character` | `--desc` + exactly 1 `--image` | `--name`, `--audio-id` |

Local files (`--image ./x.jpg`, `--video ./clip.mp4`) auto-upload to the muapi CDN.
Source video: max 100 MB / 30 s. Reference images: max 20 MB each.

**30 preset base voices:** achernar, achird, algenib, algieba, alnilam, aoede, autonoe,
callirrhoe, charon, despina, enceladus, erinome, fenrir, gacrux, iapetus, korel, aomedeia,
leda, orus, puck, pulcherrima, rasalgethi, sadachbia, sadaltager, schedar, sulafat, umbriel,
vindemiatrix, zephyr, zubenelgenubi.

---

## 🚀 Quick Start

```bash
# 0. one-time: save your key (https://muapi.ai/dashboard)
bash scripts/generate-omni.sh --add-key "YOUR_MUAPI_KEY"

# 1. Text-to-Video with native sound
bash scripts/generate-omni.sh --mode t2v \
  --prompt "A street musician plays violin on a rainy Paris evening; raindrops tap the cobblestones, a slow melancholic melody, distant cafe chatter." \
  --duration 8 --resolution 1080p --aspect-ratio 16:9 --view

# 2. Image-to-Video (1-5 references, identity preserved)
bash scripts/generate-omni.sh --mode i2v \
  --image ./hero.jpg \
  --prompt "The subject turns to face camera as golden-hour light sweeps in, leaves rustling." \
  --aspect-ratio 9:16 --view

# 3. Video Edit (restyle, keep motion + timing)
bash scripts/generate-omni.sh --mode video-edit \
  --video ./source.mp4 \
  --prompt "Restyle as hand-drawn Studio Ghibli animation; keep original camera motion and timing." \
  --trim-start 0 --trim-end 8 --view
```

## 🎭 Character-Consistent Workflow

```bash
# A. Create a reusable VOICE profile -> audio_id (free)
AUDIO=$(bash scripts/generate-omni.sh --mode audio \
  --base-voice zephyr --name "Narrator" \
  --voice-desc "Warm, calm, slight British accent, gentle pacing." \
  --json | jq -r '.audio_id')

# B. Create a reusable CHARACTER from 1 image + that voice -> character_id (free)
CHAR=$(bash scripts/generate-omni.sh --mode character \
  --image ./aria.jpg --name "Aria" \
  --desc "Young woman, short silver hair, dark trench coat, composed demeanor." \
  --audio-id "$AUDIO" --json | jq -r '.character_id')

# C. Generate video featuring the character + voice, consistently
bash scripts/generate-omni.sh --mode t2v \
  --prompt "Aria walks through a neon-lit alley at night and says: 'We are not done yet.'" \
  --character-id "$CHAR" --audio-id "$AUDIO" \
  --duration 8 --view
```

## ⚡ Async Pattern

```bash
RID=$(bash scripts/generate-omni.sh --mode t2v --prompt "..." --async --json | jq -r '.request_id')
# ... later ...
bash scripts/generate-omni.sh --result "$RID"
```

---

## 🧠 Prompting Gemini Omni

Gemini Omni rewards prompts that describe **visuals _and_ audio together**. A strong prompt
covers: subject, action, setting, lighting, camera direction, dialogue, and ambient sound.

| Component | Example |
|:---|:---|
| **Scene + light** | "A bustling Tokyo night market, neon reflections on wet pavement." |
| **Subject + detail** | "A ramen vendor laughing, steam rising from the bowl." |
| **Camera** | "Slow dolly in, 35mm, shallow depth of field." |
| **Dialogue** | Wrap spoken lines in quotes + name the speaker: `the vendor says: "Irasshaimase!"` |
| **Audio** | "Ambient chatter, sizzling broth, distant train chime. No music." |

**Tips**
- Describe sound explicitly (`soft piano underscore`, `wind through trees`, `whispered narration`).
- **Video-edit:** anchor what should *not* change — `keep the original framing`, `preserve
  subject identity`, `maintain camera path`. Name styles explicitly (`1980s VHS`, `oil painting`).
- **Localization:** rewrite dialogue in a new language while preserving lip motion — quote the
  replacement line and note the target language.
- Use `9:16` for TikTok/Reels/Shorts, `16:9` for cinematic widescreen.

---

## ❌ Common Mistakes

1. **No audio direction** — Omni generates sound natively; silence → random audio. Always
   include a sound line.
2. **Vague edits** — in `video-edit`, say what stays *and* what changes, or motion drifts.
3. **Too many references** — i2v takes max 5 images; respect the 7-slot budget on edits.
4. **Wrong character flow** — create the `audio_id` first, attach it to the character, then
   pass `--character-id` to the video call. Don't skip steps.
5. **Overlong source clips** — video-edit inputs cap at 100 MB / 30 s; trim with
   `--trim-start/--trim-end` (window ≤ 10 s).

---

## ⚙️ Notes for the Executing Agent

- Endpoints are called directly (`https://api.muapi.ai/api/v1/<endpoint>`); this skill does
  **not** depend on `schema_data.json`, because Gemini Omni is newer than the bundled schema.
- Field names sent: `prompt`, `duration`, `resolution`, `aspect_ratio`, `seed`, `audio_ids`,
  `character_ids`, `image_urls` (i2v/edit), `video_url`/`trim_start`/`trim_end` (edit), and
  `base_voice`/`profile_name`/`voice_description`/`example_dialogue` (audio),
  `descriptions`/`images_list`/`character_name` (character). Verify against the live
  `API Reference` tab on the model's playground page if a request is rejected.
- Auth: `x-api-key: $MUAPI_KEY`. Submit returns `request_id`; poll
  `GET /predictions/{request_id}/result` until `status: completed`. Free profile endpoints
  may return `audio_id` / `character_id` directly.
- Requires `curl`, `jq`, `python3` is **not** needed (payloads built with `jq`).
