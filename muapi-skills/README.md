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

There's a **dedicated, ready-to-run Gemini Omni skill** in
[`library/motion/gemini-omni/`](library/motion/gemini-omni/SKILL.md) — it wraps all 5 Omni
endpoints (`gemini-omni-text-to-video`, `-image-to-video`, `-video-edit`, plus the free
`-audio` voice profile and `-character` profile) behind one dispatcher with local-file upload,
voice/character IDs, submit-poll, `--view/--async/--json`.

```bash
# text-to-video with native synchronized audio
bash library/motion/gemini-omni/scripts/generate-omni.sh --mode t2v \
  --prompt "A Tokyo night market, neon on wet pavement, ambient chatter and sizzling broth." \
  --duration 8 --resolution 1080p --aspect-ratio 16:9 --view
```

See its [`SKILL.md`](library/motion/gemini-omni/SKILL.md) for the full character-consistent
workflow (voice → character → video) and prompting guide, and `../gemini-omni-skills.md` for
the raw endpoint/parameter reference.

> ⚠️ Gemini Omni is newer than the bundled `schema_data.json` (the only "omni" entry there is
> `midjourney-v7-omni-reference`), so the Omni skill calls the endpoints **directly** rather
> than resolving them through the schema.

---

Source: https://github.com/SamurAIGPT/Generative-Media-Skills (MIT © 2026). Vendored 2026-06-03.
