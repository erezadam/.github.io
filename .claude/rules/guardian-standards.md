---
paths:
  - "**/*.html"
  - "**/*.js"
  - "**/*.jsx"
---
# Guardian Standards — Single Source of Truth

These rules are enforced automatically by Project Guardian.

## HTML Requirements
- Every `<html>` tag MUST have `lang` and `dir` attributes
- All external resources MUST use HTTPS (never HTTP)
- Every `<img>` MUST have a descriptive `alt` attribute
- Viewport meta tag is required
- Meta description and Open Graph tags are required
- Must have a proper heading hierarchy (h1 → h2 → h3)
- `<nav>` elements need `aria-label`
- Form `<label>` elements must have `htmlFor` connecting to input

## React/JavaScript Requirements
- No `innerHTML` — use React JSX rendering
- No `console.log` in production code
- Use `ReactDOM.createRoot()` not deprecated `ReactDOM.render()`
- Functional components with hooks only, no class components
- No `eval()` or `Function()` constructor

## RTL/Hebrew Requirements
- `dir="rtl"` on `<html>` is mandatory
- `lang="he"` on `<html>` is mandatory
- Use Tailwind logical properties (`ms-*`/`me-*`) over directional (`ml-*`/`mr-*`)
- Default text alignment is `text-right`
- Verify `flex-row` direction is intentional in RTL context

## Responsive Requirements
- Grids must have mobile fallbacks (`grid-cols-1 md:grid-cols-2`)
- No fixed pixel widths over 320px
- Use mobile-first approach (`sm:` → `md:` → `lg:`)

## Security Requirements
- No hardcoded API keys, tokens, or passwords
- No `innerHTML` with user-provided data
- All CDN resources should use SRI (subresource integrity) when possible
