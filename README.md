# oh-my-qwen

> Agent orchestration for [Qwen Code](https://github.com/QwenLM/qwen-code) CLI — adapted from [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent).

Uses Qwen Code's **native subagent system** (`~/.qwen/agents/*.md` with YAML frontmatter) to give you **12 specialized agents**, **8 orchestration skills**, and hierarchical project context — all running on the **free qwen-oauth tier** (1,000 requests/day, no API key needed) or with **DASHSCOPE_API_KEY** for higher limits.

## Quick Install

> **Supported platforms:** Linux, macOS, Windows (via Git Bash, WSL, or Cygwin)

```bash
git clone https://github.com/E4crypt3d/oh-my-qwen.git
cd oh-my-qwen
bash install.sh
```

Then launch Qwen Code and complete the browser login:

```bash
qwen
```

That's it. Everything is configured.

## What You Get

### 12 Specialized Subagents

| Agent | Role | Model |
|---|---|---|
| **sisyphus** | Main ultraworker — intent analysis, task decomposition, parallel delegation | coder-model |
| **prometheus** | Strategic planner — interview-mode planning, Decision Complete principle | coder-model |
| **hephaestus** | Deep implementation — autonomous, goal-oriented, end-to-end execution | coder-model |
| **atlas** | Architecture analyst — coupling analysis, dependency mapping, extensibility | coder-model |
| **explore** | Codebase researcher — fast symbol finding, module mapping, architecture | coder-model |
| **librarian** | Documentation + external reference lookup — READMEs, API docs, library research | coder-model |
| **oracle** | High-IQ consultant — architecture decisions, deep debugging, security analysis | coder-model |
| **metis** | Pre-planning consultant — ambiguity detection, intent extraction, risk assessment | coder-model |
| **momus** | Expert reviewer — plan validation, post-implementation review, gap detection | coder-model |
| **multimodal-looker** | Vision/media specialist — image analysis, PDF extraction, diagram understanding | coder-model |
| **code-reviewer** | Quality gate — multi-level review for correctness, security, performance | coder-model |
| **testing-expert** | Test specialist — TDD, comprehensive coverage, mocking strategies | coder-model |

### 8 Orchestration Skills

| Skill | Trigger | What it does |
|---|---|---|
| **ultrawork** | Include `ultrawork` or `ulw` in prompt | Parallel multi-agent execution with Ralph Loop continuation |
| **team-run** | "use the team", "delegate to agents" | Coordinated agent pipelines (pipeline, fan-out, review loop) |
| **code-review** | "review", "audit", "check this code" | Structured multi-level code review |
| **testing** | "test", "coverage", "TDD" | Comprehensive test creation with arrange-act-assert |
| **documentation** | "document", "README", "write docs" | High-quality documentation via librarian |
| **git-master** | "commit", "rebase", "squash", "who wrote" | Atomic git operations, history search, safe operations |
| **frontend-ui-ux** | "design", "UI", "style", "layout" | Design-first frontend development, accessibility |
| **ai-slop-remover** | "clean up AI code", "remove AI slop" | Remove AI-generated code smells, make code senior-level |

### Context7 MCP (Built-in)

oh-my-qwen includes **Context7 MCP** for up-to-date documentation and code examples directly from official sources.

| Feature | Description |
|---|---|
| **Type** | Remote MCP server |
| **Endpoint** | `https://mcp.context7.com/mcp` |
| **Tools** | `query-docs`, `resolve-library-id` |

**Usage:**

- **Without API key** — Works with basic rate limits (lower usage)
- **With API key** — Higher rate limits + private repo access

**Setup:**
1. (Optional) Get your Context7 API key from [context7.com](https://context7.com) for higher limits
2. Edit `~/.qwen/oh-my-qwen.json` and replace `YOUR_API_KEY` with your key (or leave as-is for free tier)
3. Restart Qwen Code

The librarian agent will automatically use Context7 to fetch docs and code examples for any library.

### Grep by Vercel MCP (Built-in)

oh-my-qwen includes **Grep by Vercel MCP** for searching code across 1M+ public GitHub repositories.

| Feature | Description |
|---|---|
| **Type** | Remote MCP server |
| **Endpoint** | `https://mcp.grep.app` |
| **API Key** | Not required (free) |

Usage: The explore agent will use gh_grep to find code patterns and examples from real repositories.

### Optional: OtterSight Security Scanner

Security vulnerability scanner using Syft + Grype + CISA KEV + EUVD.

| Feature | Description |
|---|---|
| **Type** | Local MCP server (requires Syft + Grype) |
| **Package** | `@ottersight/mcp` |

**Setup:**

```bash
# Install prerequisites first
# macOS: brew install anchore/syft/syft anchore/grype/grype
# Linux: curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh

# Add MCP to Qwen Code
bash ~/.qwen/scripts/ottersight.sh
```

Or use directly without MCP:
```bash
npx @ottersight/cli scan .
docker run --rm -v $(pwd):/repo ghcr.io/ottersight/cli scan .
```

### Model Configuration

All agents work on **qwen-oauth** free tier — no API keys, no paid subscriptions:

- **coder-model** — All code, reasoning, implementation, orchestration

> **Free tier quota:** 1,000 requests/day, 60 req/min. No credit card required.
>
> **Higher limits:** Set `DASHSCOPE_API_KEY` environment variable for API key access with higher rate limits.

## Usage

### Ultrawork (single prompt → multi-agent execution)

Just include `ultrawork` or `ulw` in your prompt:

```
ultrawork — refactor the auth module to use JWT tokens instead of sessions,
add tests for all auth flows, and update the docs
```

Qwen Code will:
1. Decompose into sub-tasks via Sisyphus
2. Delegate to the right agents (hephaestus, testing-expert, librarian)
3. Execute in parallel where possible
4. Aggregate results and verify with Momus

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
Let the oracle analyze the authentication flow for security vulnerabilities
```

```
Use the testing-expert to write comprehensive tests for the payment module
```

### Health Check

```bash
bash ~/.qwen/scripts/oh-my-qwen-doctor.sh
```

### Generate Hierarchical Context

```bash
bash ~/.qwen/scripts/init-deep.sh /path/to/project
```

Generates `AGENTS.md` files throughout your project for agent context injection.

### View Model Assignments

```bash
bash ~/.qwen/scripts/oh-my-qwen-models.sh
```

## File Structure

```
~/.qwen/
├── settings.json                 ← qwen-oauth model providers (auto-configured)
├── oh-my-qwen.json               ← agent/category/skill/mcp mapping (includes Context7)
├── QWEN.md                       ← global orchestration context
├── agents/                       ← 12 subagents (YAML frontmatter .md files)
│   ├── sisyphus.md
│   ├── prometheus.md
│   ├── hephaestus.md
│   ├── atlas.md
│   ├── explore.md
│   ├── librarian.md
│   ├── oracle.md
│   ├── metis.md
│   ├── momus.md
│   ├── multimodal-looker.md
│   ├── code-reviewer.md
│   └── testing-expert.md
├── skills/                       ← 8 orchestration skills
│   ├── ultrawork/SKILL.md
│   ├── team-run/SKILL.md
│   ├── code-review/SKILL.md
│   ├── testing/SKILL.md
│   ├── documentation/SKILL.md
│   ├── git-master/SKILL.md
│   ├── frontend-ui-ux/SKILL.md
│   └── ai-slop-remover/SKILL.md
├── scripts/
│   ├── oh-my-qwen-doctor.sh     ← health check
│   ├── oh-my-qwen-models.sh     ← model resolution display
│   └── init-deep.sh             ← hierarchical AGENTS.md generation
└── projects/                     ← chat history (managed by Qwen Code)

~/.omg/state/                     ← ultrawork state tracking
```

## How It Works

1. **Subagents** are `.md` files with YAML frontmatter (`name`, `description`, `tools`). Qwen Code loads them automatically and delegates based on matching your prompt to the agent's `description`.

2. **Skills** are `SKILL.md` files in `~/.qwen/skills/<name>/` that provide structured workflows for specific patterns (ultrawork, review, testing, git, design, cleanup).

3. **Model providers** in `settings.json` define available models. The free qwen-oauth tier requires no API key — just browser login once. Or set `DASHSCOPE_API_KEY` for higher limits.

4. **Context loading** is hierarchical: global `~/.qwen/QWEN.md` → project root `AGENTS.md` → directory-level `AGENTS.md`. Use `init-deep.sh` to generate the hierarchy.

## Key Features from oh-my-openagent

- **Intent Gate** — Analyze true user intent before classifying or acting
- **Parallel Execution** — Fire 2-3 subagents simultaneously for independent tasks
- **Anti-Duplication** — Once delegated, never re-search the same thing manually
- **Todo Enforcement** — Agent goes idle? System yanks it back
- **Decision Complete Plans** — Prometheus plans leave ZERO decisions to implementer
- **Ralph Loop** — Self-referential continuation. Doesn't stop until 100% done
- **Failure Recovery** — After 3 failures: STOP → REVERT → DOCUMENT → CONSULT → ASK
- **AI Slop Removal** — No AI-generated code smells in comments or structure

## Uninstall

```bash
bash ~/.qwen/scripts/uninstall.sh
```

This will:
- Restore all backed up original files
- Remove all oh-my-qwen installed files (agents, skills, scripts, configs)
- Preserve your `settings.json`

Your `settings.json` is preserved — remove it manually if desired.

## License

MIT — same as oh-my-openagent upstream.
