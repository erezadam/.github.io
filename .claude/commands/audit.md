---
description: Run Project Guardian audit on the current project
---

# Project Guardian Audit

## Current project structure:
!`find . -not -path './.git/*' -not -path './node_modules/*' -type f | head -50`

## Git status:
!`git status --short`

## CLAUDE.md content:
!`cat CLAUDE.md 2>/dev/null || echo "CLAUDE.md NOT FOUND"`

## Guardian check:
!`bash .claude/scripts/guardian-check.sh 2>&1 || true`

---

Based on the project state above, run a full Project Guardian audit:
1. Check all items in .claude/skills/project-guardian/CHECKLIST.md
2. Report issues by severity (🔴 🟠 🟡 🔵)
3. Offer to auto-fix what you can
4. Give a health score out of 10
