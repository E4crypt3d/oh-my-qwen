---
name: git-master
description: Atomic commits, rebase surgery, history search, and safe git operations. Use when committing, rebasing, squashing, searching git history, or performing any git operations.
---

# Git Master

**Trigger:** "commit", "rebase", "squash", "who wrote", "when was X added", "find the commit that", "git log", "git blame", or any git operation.

## Purpose

Atomic commits, rebase surgery, history search, and safe git operations. Never destructive without explicit confirmation.

## Git Operations

### Atomic Commits
```bash
# Stage specific changes
git add <file>

# Commit with conventional message
git commit -m "type: description"

# Types: feat, fix, docs, style, refactor, test, chore
```

### Rebase Surgery
```bash
# Interactive rebase (requires user confirmation)
git rebase -i <base>

# Squash last N commits
git reset --soft HEAD~N && git commit -m "combined message"
```

### History Search
```bash
# Who wrote this line
git blame <file> -L <start>,<end>

# When was X added
git log -S "search string" --oneline

# Find the commit that
git log --all --grep="pattern"

# Bisect for bug finding
git bisect start
git bisect bad
git bisect good <known-good-commit>
```

## Safety Rules

- NEVER run `git push --force` without explicit user request
- NEVER run `git reset --hard` without explicit user request
- NEVER suppress git hooks (`--no-verify`) unless explicitly requested
- NEVER create empty commits
- ALWAYS show the diff before committing
- ALWAYS verify commit message follows conventions

## Commit Message Format

```
type(scope): description

Longer description if needed.

- Specific change 1
- Specific change 2
```

## When to Ask

- About to do a destructive operation (force push, hard reset, rebase with conflicts)
- Unresolved merge conflicts
- Detached HEAD state
- Uncertain about which branch to commit to
