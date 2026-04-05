#!/usr/bin/env bash
# oh-my-qwen installer — one-command setup for Qwen Code CLI
# Usage: bash install.sh
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

QWEN_DIR="$HOME/.qwen"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

echo -e "${CYAN}"
echo " oMoMoMoMo oh-my-qwen installer"
echo -e "${NC}"

# Pre-flight: check qwen exists
if ! command -v qwen &>/dev/null; then
  echo -e "${RED}✗ qwen CLI not found. Install it first:${NC}"
  echo "  https://github.com/QwenLM/qwen-code"
  exit 1
fi
QWEN_VER=$(qwen --version 2>/dev/null || echo "unknown")
info "qwen detected: $QWEN_VER"

# Step 1: Create directories
info "Creating directories..."
mkdir -p "$QWEN_DIR/agents"
mkdir -p "$QWEN_DIR/skills/ultrawork"
mkdir -p "$QWEN_DIR/skills/team-run"
mkdir -p "$QWEN_DIR/skills/code-review"
mkdir -p "$QWEN_DIR/skills/testing"
mkdir -p "$QWEN_DIR/skills/documentation"
mkdir -p "$QWEN_DIR/scripts"
mkdir -p "$HOME/.omg/state"
pass "Directories created"

# Step 2: Install subagents
info "Installing subagents..."
AGENT_COUNT=0
for agent_file in "$SCRIPT_DIR/agents/"*.md; do
  [[ -f "$agent_file" ]] || continue
  agent_name=$(basename "$agent_file")
  cp "$agent_file" "$QWEN_DIR/agents/$agent_name"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done
pass "$AGENT_COUNT subagents installed"

# Step 3: Install skills
info "Installing skills..."
SKILL_COUNT=0
for skill_dir in "$SCRIPT_DIR/skills/"*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name=$(basename "$skill_dir")
  mkdir -p "$QWEN_DIR/skills/$skill_name"
  cp "$skill_dir/SKILL.md" "$QWEN_DIR/skills/$skill_name/SKILL.md"
  SKILL_COUNT=$((SKILL_COUNT + 1))
done
pass "$SKILL_COUNT skills installed"

# Step 4: Install helper scripts
info "Installing helper scripts..."
SCRIPT_COUNT=0
for script_file in "$SCRIPT_DIR/scripts/"*.sh; do
  [[ -f "$script_file" ]] || continue
  script_name=$(basename "$script_file")
  cp "$script_file" "$QWEN_DIR/scripts/$script_name"
  chmod +x "$QWEN_DIR/scripts/$script_name"
  SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
done
pass "$SCRIPT_COUNT scripts installed"

# Step 5: Configure settings.json (only if no modelProviders exist)
info "Configuring settings.json..."
if [[ -f "$QWEN_DIR/settings.json" ]]; then
  HAS_PROVIDERS=$(python3 -c "
import json
try:
    d = json.load(open('$QWEN_DIR/settings.json'))
    providers = d.get('modelProviders', {})
    if providers:
        print('yes')
    else:
        print('no')
except:
    print('no')
" 2>/dev/null || echo "no")

  if [[ "$HAS_PROVIDERS" == "yes" ]]; then
    warn "modelProviders already configured in settings.json — skipping"
  else
    python3 -c "
import json
settings_path = '$QWEN_DIR/settings.json'
try:
    with open(settings_path) as f:
        settings = json.load(f)
except:
    settings = {}

settings.setdefault('security', {}).setdefault('auth', {})['selectedType'] = 'qwen-oauth'

if 'modelProviders' not in settings:
    settings['modelProviders'] = {
        'qwen-oauth': [
            {
                'id': 'coder-model',
                'name': 'Qwen Coder Model',
                'description': 'Primary coder model via Qwen OAuth free tier (1,000 req/day)'
            },
            {
                'id': 'vision-model',
                'name': 'Qwen Vision Model',
                'description': 'Vision-language model for UI/visual analysis',
                'capabilities': { 'vision': True }
            }
        ]
    }

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
" 2>/dev/null
    pass "qwen-oauth modelProviders configured"
  fi
else
  # No settings.json at all — create one
  cat > "$QWEN_DIR/settings.json" << 'SETTINGS_EOF'
{
  "security": {
    "auth": {
      "selectedType": "qwen-oauth"
    }
  },
  "model": {
    "name": "coder-model"
  },
  "$version": 3,
  "modelProviders": {
    "qwen-oauth": [
      {
        "id": "coder-model",
        "name": "Qwen Coder Model",
        "description": "Primary coder model via Qwen OAuth free tier (1,000 req/day)"
      },
      {
        "id": "vision-model",
        "name": "Qwen Vision Model",
        "description": "Vision-language model for UI/visual analysis",
        "capabilities": {
          "vision": true
        }
      }
    ]
  }
}
SETTINGS_EOF
  pass "settings.json created with qwen-oauth"
fi

# Step 6: Install oh-my-qwen.json helper config
info "Writing oh-my-qwen.json..."
cat > "$QWEN_DIR/oh-my-qwen.json" << 'CONFIG_EOF'
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",
  "_comment": "oh-my-qwen configuration — adapted from oh-my-openagent for Qwen Code CLI",
  "_note": "Uses qwen-oauth free tier (1,000 req/day). Models: coder-model, vision-model",
  "_auth": "qwen-oauth (no API key needed — browser OAuth, auto-refresh)",

  "agents": {
    "sisyphus": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/sisyphus.md",
      "description": "Main ultraworker — decomposes large tasks, delegates to sub-agents",
      "tools": ["read_file", "write_file", "read_many_files", "run_shell_command", "grep_search", "glob", "web_search"]
    },
    "prometheus": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/prometheus.md",
      "description": "Planner — creates phased execution plans, tracks milestones",
      "tools": ["read_file", "read_many_files", "write_file", "grep_search", "glob"]
    },
    "atlas": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/atlas.md",
      "description": "Architecture — designs system structure, reviews conventions",
      "tools": ["read_file", "read_many_files", "grep_search", "glob", "list_directory"]
    },
    "hephaestus": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/hephaestus.md",
      "description": "Deep worker — implements complex features end-to-end",
      "tools": ["read_file", "write_file", "read_many_files", "run_shell_command", "grep_search", "glob", "edit"]
    },
    "explore": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/explore.md",
      "description": "Codebase exploration, research, file discovery",
      "tools": ["read_file", "read_many_files", "grep_search", "glob", "list_directory", "web_search"]
    },
    "librarian": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/librarian.md",
      "description": "Documentation, summaries, config management",
      "tools": ["read_file", "write_file", "read_many_files", "edit"]
    },
    "code-reviewer": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/code-reviewer.md",
      "description": "Code review — bugs, security, performance, best practices",
      "tools": ["read_file", "read_many_files", "grep_search", "glob"]
    },
    "testing-expert": {
      "model": "qwen/coder-model",
      "file": "~/.qwen/agents/testing-expert.md",
      "description": "Testing — writes & fixes tests, coverage, mocking",
      "tools": ["read_file", "write_file", "read_many_files", "run_shell_command", "grep_search", "glob", "edit"]
    }
  },

  "categories": {
    "ultrabrain": { "model": "qwen/coder-model", "fallback": ["qwen/coder-model"] },
    "deep": { "model": "qwen/coder-model", "fallback": ["qwen/coder-model"] },
    "quick": { "model": "qwen/coder-model", "fallback": ["qwen/coder-model"] },
    "visual-engineering": { "model": "qwen/vision-model", "fallback": ["qwen/coder-model"] },
    "writing": { "model": "qwen/coder-model", "fallback": ["qwen/coder-model"] },
    "testing": { "model": "qwen/coder-model", "fallback": ["qwen/coder-model"] },
    "review": { "model": "qwen/coder-model", "fallback": ["qwen/coder-model"] }
  },

  "background_task": {
    "provider": "qwen-oauth",
    "max_concurrent_per_model": 5,
    "max_concurrent_per_provider": 5,
    "circuit_breaker": true
  },

  "skills": {
    "ultrawork": "~/.qwen/skills/ultrawork/SKILL.md",
    "team-run": "~/.qwen/skills/team-run/SKILL.md",
    "code-review": "~/.qwen/skills/code-review/SKILL.md",
    "testing": "~/.qwen/skills/testing/SKILL.md",
    "documentation": "~/.qwen/skills/documentation/SKILL.md"
  },

  "state_dir": "~/.omg/state"
}
CONFIG_EOF
pass "oh-my-qwen.json configured"

# Summary
echo ""
echo "┌─ Installation Complete ───────────────────────────────────────┐"
echo "│                                                               │"
echo "│  $AGENT_COUNT subagents  •  $SKILL_COUNT skills  •  $SCRIPT_COUNT scripts   │"
echo "│                                                               │"
echo "│  Auth: qwen-oauth (free — 1,000 requests/day)                │"
echo "│                                                               │"
echo "│  Next steps:                                                  │"
echo "│   1. Run: qwen  (complete browser login if first time)       │"
echo "│   2. Include 'ultrawork' or 'ulw' in your prompt             │"
echo "│   3. Run health check:                                        │"
echo "│      bash ~/.qwen/scripts/oh-my-qwen-doctor.sh                │"
echo "│                                                               │"
echo "└───────────────────────────────────────────────────────────────┘"
