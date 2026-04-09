---
name: team-run
description: Orchestrate multiple specialized subagents in a coordinated workflow. Use when running multiple agents together, delegating to agents, or executing complex multi-agent pipelines.
---

# Team Run

**Trigger:** Use `/team` or when the user mentions running multiple agents together,
or asks to "use the team", "run agents", "delegate to agents".

## Purpose

Orchestrates multiple specialized subagents in a coordinated workflow. Each agent
has a specific role, model assignment, and tool access defined in `.qwen/agents/`.

## Agent Directory

| Agent | File | Role | Tools |
|-------|------|------|-------|
| **sisyphus** | `sisyphus.md` | Main ultraworker — decomposes & executes complex tasks | All tools |
| **prometheus** | `prometheus.md` | Strategic planner — creates phased execution plans | Read + write files, search |
| **hephaestus** | `hephaestus.md` | Deep implementation — builds features end-to-end | All tools |
| **atlas** | `atlas.md` | Architecture analyst — reviews structure & design | Read-only + search |
| **explore** | `explore.md` | Researcher — finds code, maps architecture | Read-only + search + web |
| **librarian** | `librarian.md` | Documentation specialist — writes docs, READMEs | Read + write + edit |
| **code-reviewer** | `code-reviewer.md` | Quality gate — reviews for bugs, security, perf | Read-only + search |
| **testing-expert** | `testing-expert.md` | Test specialist — writes & fixes tests | All tools |

## Orchestration Patterns

### Pattern 1: Pipeline (Sequential)
```
explore → prometheus → hephaestus → testing-expert → code-reviewer → librarian
```
Use for: Complete feature from scratch with full quality gates.

### Pattern 2: Fan-out (Parallel)
```
         → hephaestus (feature A)
root     → hephaestus (feature B)     → code-reviewer
         → librarian (docs)
```
Use for: Independent features that can be built in parallel.

### Pattern 3: Review Loop
```
implement → code-reviewer → fix issues → re-review
```
Use for: Ensuring high quality on critical code.

### Pattern 4: Research → Plan → Execute
```
explore → atlas → prometheus → sisyphus → testing-expert
```
Use for: Large projects on unfamiliar codebases.

## How to Run

1. **Identify the pattern** needed for the task
2. **Invoke subagents by name** in your prompt or commands:
   - "Use the sisyphus subagent to..."
   - "Let the testing-expert write tests for..."
3. **Wait for each subagent** to complete before aggregating
4. **Report unified results**

## Model Assignment Reference

Agents use the model configured in `settings.json` `modelProviders`. The current
setup assigns all agents to the `qwen-oauth` provider with model selection handled
by Qwen Code's model resolution.

## Delegation Hints

Include these phrases in your commands to encourage proper delegation:
- "Delegate to [agent-name]"
- "Use the [agent-name] subagent"
- "Let [agent-name] handle this"
- "Run [agent-name] to..."
