# Skill: Ultrawork

**Trigger:** Include `ultrawork` or `ulw` in your prompt.

## Purpose

Orchestrates parallel, multi-subagent execution for complex tasks. Automatically
decomposes the user's request into sub-tasks, delegates to specialized subagents,
and aggregates results.

## How It Works

Qwen Code's native subagent system (`.qwen/agents/`) provides specialized agents.
This skill coordinates their use for maximum parallelism.

## Workflow

### Step 1: Decompose the Task
1. Parse the user's request into distinct sub-tasks
2. Classify each sub-task by the agent best suited:

| Sub-task type | Agent | When to use |
|---|---|---|
| Complex multi-feature | `sisyphus` | 3+ sub-components |
| Single feature build | `hephaestus` | End-to-end implementation |
| Planning needed | `prometheus` | Unclear approach |
| Research/exploration | `explore` | Finding code, understanding |
| Documentation | `librarian` | Writing docs, README |
| Testing | `testing-expert` | Writing/fixing tests |
| Code review | `code-reviewer` | Post-implementation review |
| Architecture review | `atlas` | Structure/design analysis |

### Step 2: Delegate to Subagents
For each sub-task:
1. Invoke the appropriate subagent by name in your command
2. Provide clear context and acceptance criteria
3. Run independent subagents in parallel where possible
4. Run dependent subagents sequentially

Example delegation:
```
Use the sisyphus subagent to: [specific task with context]
Use the hephaestus subagent to: [specific task with context]
```

### Step 3: Aggregate Results
1. Collect outputs from all subagents
2. Resolve conflicts or overlaps
3. Produce unified deliverables

### Step 4: Verify
1. Check all acceptance criteria are met
2. Run build/test commands
3. Report final status

## Concurrency Rules

- Independent subagents can run in parallel (mention them together)
- Dependent subagents must run sequentially (plan → implement → test → review)
- Maximum effective parallelism: 2-3 subagents at once

## State Tracking

Write progress to `.omg/state/ultrawork-state.json`:
```json
{
  "task": "original request",
  "started_at": "ISO timestamp",
  "subtasks": [
    {"agent": "name", "status": "completed|pending|failed", "output": "summary"}
  ]
}
```

## When NOT to Use Ultrawork

- Single-file, single-function changes (use main agent directly)
- Simple typo fixes or one-liner additions
- Tasks that are inherently sequential with no parallelism possible
