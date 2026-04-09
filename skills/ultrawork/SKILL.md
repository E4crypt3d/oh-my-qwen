---
name: ultrawork
description: Parallel, multi-subagent execution for complex tasks with 3+ sub-tasks. Automatically decomposes requests, delegates to specialized agents, executes in parallel, and aggregates results with verification.
---

# Ultrawork

**Trigger:** Include `ultrawork` or `ulw` in your prompt.

## Purpose

Orchestrates parallel, multi-subagent execution for complex tasks. Automatically decomposes the user's request into sub-tasks, delegates to specialized subagents, executes in parallel where possible, and aggregates results with verification.

## How It Works

Qwen Code's native subagent system (`~/.qwen/agents/`) provides 12 specialized agents. This skill coordinates their use for maximum parallelism and quality.

## Workflow

### Step 1: Intent Gate

Before decomposing, classify the request:
- If trivial (single file, known location) → Execute directly, skip ultrawork
- If complex (3+ sub-tasks, multiple files) → Proceed with ultrawork
- If ambiguous → Consult metis first

### Step 2: Decompose the Task

Parse the user's request into distinct, parallelizable sub-tasks. Classify each:

| Sub-task type | Agent | When to use |
|---|---|---|
| Complex multi-feature | `sisyphus` | 3+ sub-components |
| Single feature build | `hephaestus` | End-to-end implementation |
| Planning needed | `prometheus` | Unclear approach, needs roadmap |
| Research/exploration | `explore` | Finding code, understanding architecture |
| Architecture review | `atlas` | Structure/design analysis |
| Documentation | `librarian` | Writing docs, README, external research |
| Testing | `testing-expert` | Writing/fixing tests |
| Code review | `code-reviewer` | Post-implementation review |
| Architecture decision | `oracle` | Complex tradeoffs, debugging |
| Ambiguity check | `metis` | Scope clarification |
| Plan validation | `momus` | Review plan before implementation |
| Visual/media analysis | `multimodal-looker` | Images, PDFs, screenshots |

### Step 3: Delegate to Subagents

For each sub-task:
1. Invoke the appropriate subagent by name
2. Provide clear context, file paths, and acceptance criteria
3. Run **independent** subagents in parallel (mention them together)
4. Run **dependent** subagents sequentially (plan → implement → test → review)
5. Maximum effective parallelism: 2-3 subagents at once

Example delegation:
```
Use the hephaestus subagent to: implement the JWT auth middleware in src/middleware/auth.ts
Use the testing-expert subagent to: write comprehensive tests for the auth middleware
Use the librarian subagent to: document the auth API endpoints
```

### Step 4: Todo Enforcement

Create a detailed todo list before starting. Mark each task in_progress before working on it. Mark completed immediately when done. If the agent goes idle with incomplete todos, the system yanks it back.

### Step 5: Aggregate Results

1. Collect outputs from all subagents
2. Resolve conflicts or overlaps
3. Produce unified deliverables
4. Run verification (build, lint, test)

### Step 6: Self-Verify

1. Check all acceptance criteria are met
2. Run build/test commands
3. Report final status with evidence

## Concurrency Rules

- **Independent** subagents → Run in parallel (mention them together in your prompt)
- **Dependent** subagents → Run sequentially (plan → implement → test → review)
- **Maximum parallelism** → 2-3 subagents at once (respect Qwen OAuth rate limits)
- **Circuit breaker** → If a subagent fails, stop and assess before continuing

## Anti-Duplication Rule (CRITICAL)

Once you delegate exploration to a subagent, DO NOT perform the same search yourself. Continue with non-overlapping work only. If none exists, end your response and wait for the notification.

## State Tracking

Write progress to `~/.omg/state/ultrawork-state.json`:
```json
{
  "task": "original request",
  "started_at": "ISO timestamp",
  "subtasks": [
    {"agent": "name", "status": "completed|pending|failed", "output": "summary"}
  ]
}
```

## Ralph Loop (Self-Referential Continuation)

If the task is not fully complete after the first pass:
1. Review what remains undone
2. Re-invoke the necessary subagents
3. Repeat until 100% complete
4. Do NOT stop halfway — the loop continues until done

## When NOT to Use Ultrawork

- Single-file, single-function changes (use main agent directly)
- Simple typo fixes or one-liner additions
- Tasks that are inherently sequential with no parallelism possible
- User is still giving context or constraints (gather first)
