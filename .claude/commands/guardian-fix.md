---
description: Auto-fix all detected guardian issues
argument-hint: "[all|security|a11y|rtl|responsive|seo]"
---

# Guardian Auto-Fix: $ARGUMENTS

## Step 1 — Run audit first:
!`bash .claude/scripts/guardian-check.sh 2>&1 || true`

## Step 2 — Current file list:
!`find . -name "*.html" -not -path './.git/*' 2>/dev/null`

## Step 3 — Fix

Based on the audit results above:
1. Filter to category: "$ARGUMENTS" (or all if empty)
2. Fix each issue, showing BEFORE and AFTER for each change
3. Re-run the audit to confirm all fixes work
4. Summarize every change made

Fix priority: 🔴 CRITICAL first, then 🟠 HIGH, then 🟡 MEDIUM.
NEVER change application logic — only fix structure, accessibility, and standards.
