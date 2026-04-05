# oh-my-qwen

> Agent orchestration for [Qwen Code](https://github.com/QwenLM/qwen-code) CLI — adapted from [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent).

Uses Qwen Code's **native subagent system** (`.qwen/agents/*.md` with YAML frontmatter) to give you 8 specialized agents, 5 orchestration skills, and a model fallback chain — all running on the **free qwen-oauth tier** (1,000 requests/day, no API key needed).

## Quick Install

```bash
git clone https://github.com/E4crypt3d/oh-my-qwen.git
cd oh-my-qwen
bash install.sh
```

Or download this folder and run:

```bash
bash install.sh
```

Then launch Qwen Code and complete the browser login:

```bash
qwen
```

That's it. Everything is configured.

## What You Get

### 8 Specialized Subagents

| Agent | Role | Tools |
|-------|------|-------|
| **sisyphus** | Main ultraworker — decomposes & executes complex tasks | All |
| **prometheus** | Strategic planner — phased execution plans | Read/write/search |
| **hephaestus** | Deep implementation — builds features end-to-end | All |
| **atlas** | Architecture analyst — reviews structure & design | Read-only+search |
| **explore** | Researcher — finds code, maps architecture | Read-only+search+web |
| **librarian** | Documentation — writes docs, READMEs, summaries | Read/write/edit |
| **code-reviewer** | Quality gate — reviews for bugs, security, perf | Read-only+search |
| **testing-expert** | Testing — writes & fixes tests | All |

### 5 Orchestration Skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| **ultrawork** | Include `ultrawork` or `ulw` in prompt | Parallel multi-agent execution |
| **team-run** | `/team` or "use the team" | Coordinated agent pipelines |
| **code-review** | "review", "audit" | Structured review via code-reviewer |
| **testing** | "test", "coverage" | Test creation via testing-expert |
| **documentation** | "document", "README" | Docs via librarian |

### Model Configuration

All agents run on **qwen-oauth** free tier — no API keys, no paid subscriptions:

- **coder-model** — all code, reasoning, implementation
- **vision-model** — UI analysis, image understanding

> **Quota:** 1,000 requests/day, 60 req/min. No credit card required.

## Usage

### Ultrawork (single prompt → multi-agent execution)

Just include `ultrawork` or `ulw` in your prompt:

```
ultrawork — refactor the auth module to use JWT tokens instead of sessions,
add tests for all auth flows, and update the docs
```

Qwen Code will:
1. Decompose into sub-tasks
2. Delegate to the right agents (sisyphus, hephaestus, testing-expert, librarian)
3. Execute in parallel where possible
4. Aggregate results and verify

### Team Pipeline (sequential quality gates)

```
Use the pipeline: explore → prometheus → hephaestus → testing-expert → code-reviewer

Task: build a REST API for user management with CRUD operations
```

### Direct Agent Invocation

```
Use the sisyphus subagent to implement the search feature across
the API, frontend, and database layers
```

```
Let the testing-expert write comprehensive tests for the payment module
```

```
Use the code-reviewer to audit the recent changes in src/auth/
```

### Health Check

```bash
bash ~/.qwen/scripts/oh-my-qwen-doctor.sh
```

### View Model Assignments

```bash
bash ~/.qwen/scripts/oh-my-qwen-models.sh
```

## File Structure

```
~/.qwen/
├── settings.json                 ← qwen-oauth model providers (auto-configured)
├── oh-my-qwen.json               ← agent/category/skill mapping
├── QWEN.md                       ← global orchestration context
├── agents/                       ← 8 subagents (YAML frontmatter .md files)
│   ├── sisyphus.md
│   ├── prometheus.md
│   ├── hephaestus.md
│   ├── atlas.md
│   ├── explore.md
│   ├── librarian.md
│   ├── code-reviewer.md
│   └── testing-expert.md
├── skills/                       ← 5 orchestration skills
│   ├── ultrawork/SKILL.md
│   ├── team-run/SKILL.md
│   ├── code-review/SKILL.md
│   ├── testing/SKILL.md
│   └── documentation/SKILL.md
├── scripts/
│   ├── oh-my-qwen-doctor.sh     ← health check
│   └── oh-my-qwen-models.sh     ← model resolution display
└── projects/                     ← chat history (managed by Qwen Code)

~/.omg/state/                     ← ultrawork state tracking
```

## How It Works

1. **Subagents** are `.md` files with YAML frontmatter (`name`, `description`, `tools`). Qwen Code loads them automatically and delegates based on matching your prompt to the agent's `description`.

2. **Skills** are `SKILL.md` files in `.qwen/skills/<name>/` that provide structured workflows for specific patterns (ultrawork, review, testing, etc.).

3. **Model providers** in `settings.json` define available models. The free qwen-oauth tier requires no API key — just browser login once.

4. **Context loading** is hierarchical: global `~/.qwen/QWEN.md` → ancestor files → project root file.

## Uninstall

```bash
rm -rf ~/.qwen/agents ~/.qwen/skills ~/.qwen/scripts ~/.qwen/oh-my-qwen.json
rm -rf ~/.omg
```

Your `settings.json` and `QWEN.md` are preserved — remove them manually if desired.

## License

MIT — same as oh-my-openagent upstream.
