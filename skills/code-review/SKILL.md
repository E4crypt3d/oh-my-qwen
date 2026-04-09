---
name: code-review
description: Systematic code review with structured output and actionable findings. Use when reviewing code, auditing quality, checking for bugs, security vulnerabilities, or performance issues.
---

# Code Review

**Trigger:** Use after implementation, or when the user says "review", "audit",
"check this code", "security review", or mentions code quality.

## Purpose

Systematic code review using the `code-reviewer` subagent, with structured
output and actionable findings.

## Review Levels

### Quick Check
- Read the changed files
- Flag obvious issues
- ~5 minute review
- Use for: Small PRs, minor changes

### Standard Review
- Read changed files and their dependencies
- Check correctness, security, performance, style
- ~15 minute review
- Use for: Normal feature changes

### Deep Audit
- Full dependency analysis
- Security-focused review
- Performance profiling considerations
- ~30 minute review
- Use for: Critical paths, security-sensitive code

## Review Checklist

### Correctness (must pass)
- [ ] Logic is sound — no null references, off-by-one, race conditions
- [ ] All code paths tested
- [ ] Error handling is complete
- [ ] Types are correct and safe

### Security (must pass)
- [ ] No secrets, keys, or credentials in code
- [ ] Input validation on all user-facing inputs
- [ ] No injection vectors (SQL, XSS, command)
- [ ] Proper authorization checks

### Performance (should pass)
- [ ] No N+1 queries or unnecessary loops
- [ ] Appropriate data structures
- [ ] No wasteful allocations in hot paths

### Maintainability (should pass)
- [ ] Clear, descriptive names
- [ ] Focused functions (not too long)
- [ ] Follows project conventions
- [ ] Complex logic explained

## How to Run

```
Use the code-reviewer subagent to review [specific files/modules]
Focus on: [specific concerns, or "all categories"]
```

## Output Format

```
## Code Review Results

### Critical (must fix before merge)
- `file:line` — Issue → Fix

### Warnings (should fix)
- `file:line` — Issue → Fix

### Suggestions (nice to have)
- `file:line` — Issue → Suggestion

**Score:** Pass / Needs Work / Block
```
