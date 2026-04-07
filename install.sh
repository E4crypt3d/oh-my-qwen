#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

QWEN_DIR="$HOME/.qwen"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$QWEN_DIR/.backup"

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

backup_existing() {
    local file="$1"
    local rel_path="${file#$QWEN_DIR/}"
    if [[ -f "$file" ]]; then
        local backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        info "Backed up: $rel_path"
    fi
}

echo -e "${CYAN}"
echo " oMoMoMoMo oh-my-qwen installer"
echo -e "${NC}"

if ! command -v qwen &>/dev/null; then
  echo -e "${RED}✗ qwen CLI not found. Install it first:${NC}"
  echo "  https://github.com/QwenLM/qwen-code"
  exit 1
fi
QWEN_VER=$(qwen --version 2>/dev/null || echo "unknown")
info "qwen detected: $QWEN_VER"

if command -v python3 &>/dev/null; then
  PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
  PYTHON_CMD="python"
else
  echo -e "${RED}✗ Python not found. Install Python 3.6+ first.${NC}"
  exit 1
fi
info "Python detected: $PYTHON_CMD"

info "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

info "Backing up existing files..."
backup_existing "$QWEN_DIR/settings.json"
backup_existing "$QWEN_DIR/oh-my-qwen.json"
backup_existing "$QWEN_DIR/QWEN.md"
if [[ -d "$QWEN_DIR/agents" ]]; then
    for f in "$QWEN_DIR/agents"/*.md; do
        [[ -f "$f" ]] && backup_existing "$f"
    done
fi
if [[ -d "$QWEN_DIR/skills" ]]; then
    for f in "$QWEN_DIR/skills"/*/SKILL.md; do
        [[ -f "$f" ]] && backup_existing "$f"
    done
fi
if [[ -d "$QWEN_DIR/scripts" ]]; then
    for f in "$QWEN_DIR/scripts"/*.sh; do
        [[ -f "$f" ]] && backup_existing "$f"
    done
fi
pass "Backup complete"

info "Creating directories..."
mkdir -p "$QWEN_DIR/agents"
mkdir -p "$QWEN_DIR/skills/ultrawork"
mkdir -p "$QWEN_DIR/skills/team-run"
mkdir -p "$QWEN_DIR/skills/code-review"
mkdir -p "$QWEN_DIR/skills/testing"
mkdir -p "$QWEN_DIR/skills/documentation"
mkdir -p "$QWEN_DIR/skills/git-master"
mkdir -p "$QWEN_DIR/skills/frontend-ui-ux"
mkdir -p "$QWEN_DIR/skills/ai-slop-remover"
mkdir -p "$QWEN_DIR/scripts"
mkdir -p "$HOME/.omg/state"
pass "Directories created"

info "Installing subagents..."
AGENT_COUNT=0
for agent_file in "$SCRIPT_DIR/agents/"*.md; do
  [[ -f "$agent_file" ]] || continue
  agent_name=$(basename "$agent_file")
  cp "$agent_file" "$QWEN_DIR/agents/$agent_name"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done
pass "$AGENT_COUNT subagents installed"

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

info "Configuring settings.json..."
if [[ -f "$QWEN_DIR/settings.json" ]]; then
  HAS_PROVIDERS=$($PYTHON_CMD -c "
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
    warn "modelProviders already configured — skipping"
  else
    $PYTHON_CMD -c "
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
            }
        ]
    }

if 'model' not in settings:
    settings['model'] = {}
settings['model']['name'] = 'coder-model'

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
" 2>/dev/null
    pass "qwen-oauth modelProviders configured"
  fi
else
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
  "modelProviders": {
    "qwen-oauth": [
      {
        "id": "coder-model",
        "name": "Qwen Coder Model",
        "description": "Primary coder model via Qwen OAuth free tier (1,000 req/day)"
      }
    ]
  }
}
SETTINGS_EOF
  pass "settings.json created with qwen-oauth"
fi

info "Writing oh-my-qwen.json..."
cp "$SCRIPT_DIR/oh-my-qwen.json" "$QWEN_DIR/oh-my-qwen.json"
pass "oh-my-qwen.json configured (including Context7 MCP)"

echo ""
echo -e "${CYAN}────────────────────────────────────────${NC}"
echo -e "${CYAN}  Context7 MCP Configuration (optional) ${NC}"
echo -e "${CYAN}────────────────────────────────────────${NC}"
echo "  Context7 works without an API key (basic limits)."
echo "  With an API key: higher rate limits + private repos."
echo ""
read -p "  Do you have a Context7 API key? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "  Enter your Context7 API key: " CONTEXT7_API_KEY
  if [[ -n "$CONTEXT7_API_KEY" ]]; then
    $PYTHON_CMD -c "
import json
settings_path = '$QWEN_DIR/oh-my-qwen.json'
with open(settings_path) as f:
    settings = json.load(f)
settings['mcpServers']['context7']['headers']['CONTEXT7_API_KEY'] = '$CONTEXT7_API_KEY'
with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
    pass "Context7 API key configured"
  fi
else
  info "Using Context7 free tier (no API key required)"
fi

info "Writing QWEN.md global context..."
cp "$SCRIPT_DIR/QWEN.md" "$QWEN_DIR/QWEN.md"
pass "QWEN.md installed"

echo ""
echo "┌─ Installation Complete ───────────────────────────────────────┐"
echo "│                                                               │"
echo "│  $AGENT_COUNT subagents  •  $SKILL_COUNT skills  •  $SCRIPT_COUNT scripts   │"
echo "│  Context7 MCP: Enabled                                        │"
echo "│                                                               │"
echo "│  Auth: qwen-oauth (free — 1,000 requests/day)                │"
echo "│  API Key: Set DASHSCOPE_API_KEY for higher limits             │"
echo "│                                                               │"
echo "│  Next steps:                                                  │"
echo "│   1. Run: qwen  (complete browser login if first time)       │"
echo "│   2. Include 'ultrawork' or 'ulw' in your prompt             │"
echo "│   3. Run health check:                                        │"
echo "│      bash ~/.qwen/scripts/oh-my-qwen-doctor.sh                │"
echo "│                                                               │"
echo "└───────────────────────────────────────────────────────────────┘"
