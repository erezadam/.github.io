#!/bin/bash
# Project Guardian - New Project Initializer
# Creates the full .claude structure for a new project
# Usage: bash .claude/scripts/guardian-init.sh [project-name] [project-type]

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PROJECT_NAME="${1:-$(basename $PROJECT_ROOT)}"
PROJECT_TYPE="${2:-html}"  # html, node, python, react

echo "🛡️ Project Guardian - Initializing: $PROJECT_NAME ($PROJECT_TYPE)"

# Create folder structure
mkdir -p "$PROJECT_ROOT/.claude/rules"
mkdir -p "$PROJECT_ROOT/.claude/commands"
mkdir -p "$PROJECT_ROOT/.claude/skills/project-guardian"
mkdir -p "$PROJECT_ROOT/.claude/agents"
mkdir -p "$PROJECT_ROOT/.claude/scripts"

# Copy guardian scripts if not present
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -f "$PROJECT_ROOT/.claude/scripts/guardian-check.sh" ]; then
    cp "$SCRIPT_DIR/guardian-check.sh" "$PROJECT_ROOT/.claude/scripts/" 2>/dev/null
    chmod +x "$PROJECT_ROOT/.claude/scripts/guardian-check.sh"
fi

# Create .gitignore if missing
if [ ! -f "$PROJECT_ROOT/.gitignore" ]; then
    cat > "$PROJECT_ROOT/.gitignore" << 'GITIGNORE'
CLAUDE.local.md
.claude/settings.local.json
.env
.env.*
.DS_Store
Thumbs.db
node_modules/
GITIGNORE
    echo "✅ Created .gitignore"
fi

# Create CLAUDE.md if missing
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    cat > "$PROJECT_ROOT/CLAUDE.md" << CLAUDEMD
# Project: $PROJECT_NAME

## Commands
\`\`\`
# TODO: Add your build/dev/test commands here
\`\`\`

## Architecture
- TODO: Describe your tech stack
- TODO: Describe folder structure

## Conventions
- TODO: Add naming conventions
- TODO: Add code style rules

## Watch Out For
- TODO: Add gotchas and pitfalls
CLAUDEMD
    echo "✅ Created CLAUDE.md (edit this first!)"
fi

# Create settings.json if missing
if [ ! -f "$PROJECT_ROOT/.claude/settings.json" ]; then
    cat > "$PROJECT_ROOT/.claude/settings.json" << 'SETTINGS'
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git push *)",
      "Bash(ls *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Read(./.env)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "bash .claude/scripts/guardian-check.sh"
      }
    ]
  }
}
SETTINGS
    echo "✅ Created settings.json with guardian hook"
fi

echo ""
echo "🛡️ Project Guardian initialized!"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md with your project details"
echo "  2. Add rules to .claude/rules/"
echo "  3. Add commands to .claude/commands/"
echo "  4. Run: claude '/project:audit' to verify"
echo ""
