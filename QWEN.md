# QWEN.md — oh-my-qwen Orchestration Context

> This file provides global context for Qwen Code when oh-my-qwen is installed.
> It defines the agent ecosystem, orchestration patterns, and operational rules.

## Agent Roster

| Agent | Role | When to Invoke |
|---|---|---|
| **sisyphus** | Main ultrawork orchestrator | Complex tasks, "ultrawork", "ulw", 3+ sub-tasks |
| **prometheus** | Strategic planner | "plan", "strategy", "phased", "roadmap" |
| **hephaestus** | Deep implementation worker | "implement", "build", "create" for non-trivial features |
| **atlas** | Architecture analyst | "architecture", "design", "review structure" |
| **explore** | Codebase researcher | "where is X", "how does Y work", "find usages" |
| **librarian** | Documentation + reference lookup | "write docs", "README", "how do I use [library]" |
| **oracle** | High-IQ consultant | Architecture decisions, 2+ failed fixes, security review |
| **metis** | Pre-planning consultant | Ambiguous requests, scope clarification |
| **momus** | Expert reviewer | Plan validation, post-implementation review |
| **multimodal-looker** | Vision/media specialist | "look at this image", "analyze this PDF" |
| **code-reviewer** | Quality gate | "review this", "code review", "security audit" |
| **testing-expert** | Test specialist | "write tests", "coverage", "TDD" |

## Orchestration Patterns

### Ultrawork (Parallel Multi-Agent)
```
sisyphus → [explore | hephaestus | testing-expert | librarian] → code-reviewer → momus
```
Trigger: Include "ultrawork" or "ulw" in prompt.

### Research → Plan → Execute
```
explore → atlas → prometheus → hephaestus → testing-expert → code-reviewer
```
Trigger: Large, unfamiliar codebase projects.

### Review Loop
```
implement → code-reviewer → fix issues → re-review → momus
```
Trigger: Critical code, security-sensitive changes.

### Quick Task
```
Direct execution (no delegation needed)
```
Trigger: Single-file changes, typo fixes, simple modifications.

## Model Configuration

All agents run on **qwen-oauth** free tier by default:
- **coder-model** — All code, reasoning, implementation (text + image support)

> **Quota:** 1,000 requests/day, 60 req/min. No credit card required.
> API key users: Set DASHSCOPE_API_KEY for higher limits.

## Operational Rules

### Intent Gate
Before acting, classify the request:
- Research → explore/synthesize/answer
- Implementation → plan/delegate/execute
- Investigation → explore/report
- Evaluation → assess/propose/wait
- Fix → diagnose/fix minimally

### Delegation Rules
1. Specialized agent exists → Use it
2. 2+ independent sub-tasks → Fire in parallel
3. Trivial task → Execute directly

### Anti-Duplication
Once delegated, do NOT re-search the same thing manually.

### Verification
- Diagnostics clean on changed files
- Build passes (if applicable)
- Tests pass (or pre-existing failures noted)
- User's original request fully addressed

### Failure Recovery
After 3 consecutive failures: STOP → REVERT → DOCUMENT → CONSULT oracle → ASK USER

## Skills

| Skill | Trigger | Purpose |
|---|---|---|
| **ultrawork** | "ultrawork", "ulw" | Parallel multi-agent execution |
| **team-run** | "use the team", "delegate" | Coordinated agent pipelines |
| **code-review** | "review", "audit" | Structured code review |
| **testing** | "test", "coverage", "TDD" | Comprehensive test creation |
| **documentation** | "document", "README" | High-quality documentation |
| **git-master** | "commit", "rebase", "squash" | Atomic git operations |
| **frontend-ui-ux** | "design", "UI", "style" | Design-first frontend work |
| **ai-slop-remover** | "clean up AI code" | Remove AI-generated code smells |

## File Locations

- **Agents:** `~/.qwen/agents/*.md`
- **Skills:** `~/.qwen/skills/*/SKILL.md`
- **Config:** `~/.qwen/oh-my-qwen.json`
- **State:** `~/.omg/state/`
- **Scripts:** `~/.qwen/scripts/`
