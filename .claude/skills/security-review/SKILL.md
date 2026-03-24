---
name: security-review
description: Security audit for the landing page. Use when reviewing code for vulnerabilities, checking for exposed secrets, or before deployments.
allowed-tools: Read, Grep, Glob
---

Analyze the project for security vulnerabilities:

1. Check for hardcoded secrets, API keys, or tokens
2. Verify all external CDN URLs use HTTPS
3. Check for XSS vulnerabilities (innerHTML, dangerouslySetInnerHTML)
4. Verify user input sanitization in contact form
5. Check for mixed content issues
6. Review Content Security Policy headers if present

Report findings with severity levels: CRITICAL, WARNING, INFO
