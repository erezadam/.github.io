---
description: Quick project health score dashboard
---

# 🛡️ Project Guardian — Health Dashboard

## Files:
!`find . -name "*.html" -not -path './.git/*' 2>/dev/null | head -20`

## Guardian check:
!`bash .claude/scripts/guardian-check.sh 2>&1 || true`

## CLAUDE.md size:
!`wc -l CLAUDE.md 2>/dev/null || echo "MISSING"`

---

Run a quick health check across 6 categories and output a dashboard:

| Category | Score | Status |
|----------|-------|--------|
| Security | ?/100 | |
| Accessibility | ?/100 | |
| RTL/Hebrew | ?/100 | |
| Responsive | ?/100 | |
| Code Quality | ?/100 | |
| SEO/Meta | ?/100 | |
| **Overall** | **?/100** | |

Then list the top 3 most critical issues to fix next.
If overall score < 70, recommend running `/project:guardian-fix all`.
