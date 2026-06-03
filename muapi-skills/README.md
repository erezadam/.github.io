# MuAPI Skills (vendored)

The actual, runnable skill files for working with MuAPI — copied from the open-source
MIT repo [SamurAIGPT/Generative-Media-Skills](https://github.com/SamurAIGPT/Generative-Media-Skills).
These are free; only the MuAPI **API key** consumes credits.

## What's here

| Skill | File | Use |
|-------|------|-----|
| Media generation | `core/media/SKILL.md` + scripts | text-to-image, **text-to-video**, **image-to-video**, music, upload |
| Editing | `core/edit/SKILL.md` + scripts | image edit/enhance, lipsync, video effects |
| Platform | `core/platform/SKILL.md` + scripts | API-key setup, result polling |
| Model registry | `schema_data.json` | maps a `--model` name → API endpoint + valid params |

Each `*.sh` resolves the model→endpoint from `schema_data.json`, `POST`s to
`https://api.muapi.ai/api/v1/{endpoint}`, then polls `/predictions/{request_id}/result`
until `status: completed`. Auth header: `x-api-key: $MUAPI_KEY`.

## Setup

```bash
# 1. set your key (get it at https://muapi.ai/dashboard)
bash core/platform/setup.sh --add-key "YOUR_MUAPI_KEY"   # or: export MUAPI_KEY=...

# 2. generate
bash core/media/generate-video.sh -p "ocean waves at golden hour" -m minimax-pro --view
```

## Using these skills with Gemini Omni

> ⚠️ Gemini Omni is brand-new (MuAPI, 2026) and is **not yet in the bundled
> `schema_data.json`** (the only "omni" entry here is `midjourney-v7-omni-reference`).
> The 5 Gemini Omni endpoints are: `gemini-omni-text-to-video`, `gemini-omni-image-to-video`,
> `gemini-omni-video-edit`, plus the free `gemini-omni-audio` (voice profile) and
> `gemini-omni-character` (character profile). See `../gemini-omni-skills.md` for full params.

Two ways to drive Omni:

**A) Call the endpoint directly** (no schema entry needed):

```bash
curl -s -X POST "https://api.muapi.ai/api/v1/gemini-omni-text-to-video" \
  -H "x-api-key: $MUAPI_KEY" -H "Content-Type: application/json" \
  -d '{"prompt":"A Tokyo night market, neon on wet pavement, ambient chatter","duration":8,"resolution":"1080p","aspect_ratio":"16:9"}'
# → returns {"request_id": "..."} ; then poll:
bash core/platform/check-result.sh <request_id>
```

**B) Register Omni in `schema_data.json`** so `generate-video.sh -m gemini-omni-text-to-video`
works. Add an entry like:

```json
{
  "name": "gemini-omni-text-to-video",
  "input_schema": { "schemas": { "input_data": {
    "endpoint_url": "gemini-omni-text-to-video",
    "properties": { "prompt": {}, "duration": {}, "resolution": {}, "aspect_ratio": {},
                    "audio_ids": {}, "character_ids": {}, "seed": {} }
  }}}
}
```

---

Source: https://github.com/SamurAIGPT/Generative-Media-Skills (MIT © 2026). Vendored 2026-06-03.
