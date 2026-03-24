#!/bin/bash
# Project Guardian - Automated project health check
# Runs after file changes via Claude Code hooks
# Exit 0 = OK, Exit 1 = issues found (blocks action)
# Output goes to stderr for Claude to see

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ISSUES=""
WARNINGS=""

# ============================================
# STRUCTURE CHECKS
# ============================================

# Check CLAUDE.md exists
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    ISSUES="$ISSUES\n❌ CLAUDE.md missing at project root"
fi

# Check .claude/ folder exists
if [ ! -d "$PROJECT_ROOT/.claude" ]; then
    ISSUES="$ISSUES\n❌ .claude/ folder missing"
fi

# Check settings.json exists
if [ ! -f "$PROJECT_ROOT/.claude/settings.json" ]; then
    WARNINGS="$WARNINGS\n⚠️ .claude/settings.json missing - no permissions configured"
fi

# Check .gitignore exists and protects sensitive files
if [ ! -f "$PROJECT_ROOT/.gitignore" ]; then
    ISSUES="$ISSUES\n❌ .gitignore missing"
elif ! grep -q "CLAUDE.local.md" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    WARNINGS="$WARNINGS\n⚠️ CLAUDE.local.md not in .gitignore"
elif ! grep -q ".env" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    WARNINGS="$WARNINGS\n⚠️ .env not in .gitignore"
fi

# ============================================
# SECURITY CHECKS
# ============================================

# Check for exposed secrets in tracked files
SECRET_PATTERNS='(api[_-]?key|secret[_-]?key|password|token|credentials)\s*[:=]\s*["\x27][^\s]+'
FOUND_SECRETS=$(grep -rlEi "$SECRET_PATTERNS" "$PROJECT_ROOT"/*.html "$PROJECT_ROOT"/*.js "$PROJECT_ROOT"/*.json 2>/dev/null | grep -v node_modules | grep -v .git | grep -v package-lock)
if [ -n "$FOUND_SECRETS" ]; then
    ISSUES="$ISSUES\n❌ SECURITY: Possible secrets found in: $FOUND_SECRETS"
fi

# Check for .env file that shouldn't be committed
if git ls-files --cached "$PROJECT_ROOT/.env" 2>/dev/null | grep -q ".env"; then
    ISSUES="$ISSUES\n❌ SECURITY: .env file is tracked by git!"
fi

# ============================================
# CODE QUALITY CHECKS (for HTML/JS projects)
# ============================================

# Check HTML files for common issues
for htmlfile in "$PROJECT_ROOT"/*.html; do
    [ -f "$htmlfile" ] || continue

    # Check for console.log in production code
    if grep -q "console\.log" "$htmlfile" 2>/dev/null; then
        WARNINGS="$WARNINGS\n⚠️ console.log found in $(basename $htmlfile) - remove for production"
    fi

    # Check for HTTP (not HTTPS) external resources
    if grep -qE 'src="http://' "$htmlfile" 2>/dev/null; then
        ISSUES="$ISSUES\n❌ Non-HTTPS resource in $(basename $htmlfile)"
    fi

    # Check for missing lang attribute
    if grep -q "<html" "$htmlfile" && ! grep -qE '<html[^>]+lang=' "$htmlfile" 2>/dev/null; then
        WARNINGS="$WARNINGS\n⚠️ Missing lang attribute in $(basename $htmlfile)"
    fi

    # Check for missing viewport meta
    if ! grep -q "viewport" "$htmlfile" 2>/dev/null; then
        WARNINGS="$WARNINGS\n⚠️ Missing viewport meta tag in $(basename $htmlfile)"
    fi
done

# ============================================
# CLAUDE.md QUALITY CHECKS
# ============================================

if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    LINE_COUNT=$(wc -l < "$PROJECT_ROOT/CLAUDE.md")
    if [ "$LINE_COUNT" -gt 200 ]; then
        WARNINGS="$WARNINGS\n⚠️ CLAUDE.md is $LINE_COUNT lines (recommended: under 200). Consider splitting to .claude/rules/"
    fi
fi

# ============================================
# OUTPUT RESULTS
# ============================================

if [ -n "$ISSUES" ]; then
    echo -e "🛡️ PROJECT GUARDIAN - Issues Found:" >&2
    echo -e "$ISSUES" >&2
    if [ -n "$WARNINGS" ]; then
        echo -e "\nWarnings:" >&2
        echo -e "$WARNINGS" >&2
    fi
    exit 1
fi

if [ -n "$WARNINGS" ]; then
    echo -e "🛡️ PROJECT GUARDIAN - Warnings:" >&2
    echo -e "$WARNINGS" >&2
    exit 0
fi

# All clean - silent exit
exit 0
