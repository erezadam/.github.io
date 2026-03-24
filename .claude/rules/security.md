# Security Rules

- IMPORTANT: Never include API keys, tokens, or secrets in HTML files
- Never load scripts from untrusted CDNs
- Sanitize any user-generated content before rendering (prevent XSS)
- Use HTTPS for all external resource URLs
- Do not use innerHTML with user input — use React's JSX rendering
- Contact form data should never be logged to console in production
