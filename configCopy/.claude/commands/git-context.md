---
description: Summarize current repo state (status/diff/branch/recent commits) and propose next action
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
---
## Context
- Branch: !`git branch --show-current`
- Status: !`git status --porcelain`
- Diff vs HEAD: !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## Task
Summarize what's currently in-flight and list the most sensible next 3 actions.
