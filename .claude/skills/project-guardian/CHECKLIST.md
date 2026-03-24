# Project Guardian Checklist

## Structure ✅
- [ ] CLAUDE.md exists at project root
- [ ] CLAUDE.md is under 200 lines
- [ ] .claude/ folder exists
- [ ] .claude/settings.json exists with permissions
- [ ] .claude/rules/ has at least one rule file
- [ ] .claude/commands/ has at least one command
- [ ] .gitignore exists
- [ ] CLAUDE.local.md is in .gitignore
- [ ] .env is in .gitignore

## Security 🔒
- [ ] No hardcoded secrets in source files
- [ ] .env is not tracked by git
- [ ] All external resources use HTTPS
- [ ] Destructive commands are in deny list
- [ ] .env files are in deny list for Read

## Code Quality 📝
- [ ] No console.log in production code
- [ ] HTML has lang attribute
- [ ] HTML has viewport meta tag
- [ ] Images have alt attributes
- [ ] Interactive elements have aria-labels

## CLAUDE.md Quality 📋
- [ ] Has Commands section with build/dev/test
- [ ] Has Architecture section
- [ ] Has Conventions section
- [ ] Has Watch Out For section
- [ ] No linter rules (those belong in .eslintrc)
- [ ] Focused on things linters can't enforce
