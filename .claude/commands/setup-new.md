---
description: Initialize Project Guardian on a new project
argument-hint: [project-name]
---

# Initialize Project Guardian for: $ARGUMENTS

Run the initialization:
!`bash .claude/scripts/guardian-init.sh "$ARGUMENTS" 2>&1`

Now help the user set up their project properly:

1. Ask about their tech stack (language, framework, database)
2. Ask about their team size and workflow
3. Generate a tailored CLAUDE.md based on their answers
4. Create appropriate .claude/rules/ files for their stack
5. Create 2-3 useful .claude/commands/ for their workflow
6. Verify everything with a guardian audit

Be conversational and guide them step by step.
