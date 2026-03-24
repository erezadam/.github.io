# Project: זהבה - אדם אסא (Landing Page)

## Commands
```
# Open locally in browser
open landing-page-html.html

# Deploy via GitHub Pages (push to main)
git push origin main
```

## Architecture
- Single-page HTML app with inline React (Babel standalone)
- Tailwind CSS via CDN
- RTL layout (Hebrew, dir="rtl")
- GitHub Pages for hosting

## Conventions
- IMPORTANT: All UI text MUST be in Hebrew
- IMPORTANT: Always maintain RTL direction
- Use Tailwind utility classes, not custom CSS
- React components use functional style with hooks
- Keep everything in a single HTML file unless explicitly asked to split
- Image uploads handled client-side only (no backend)

## Watch Out For
- Babel standalone is loaded via CDN — no build step needed
- React is loaded via CDN, not npm — do NOT add package.json
- All scripts use `type="text/babel"` for JSX support
- GitHub Pages serves from main branch root
- No server-side code — everything runs in the browser
