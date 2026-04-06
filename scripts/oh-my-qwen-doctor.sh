#!/usr/bin/env bash
# oh-my-qwen doctor — verify installation and configuration health
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

OK=0
WARN=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; OK=$((OK + 1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARN=$((WARN + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

echo -e "${CYAN} oMoMoMoMo Doctor (oh-my-qwen)${NC}"
echo ""

QWEN_DIR="$HOME/.qwen"

if command -v python3 &>/dev/null; then
  PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
  PYTHON_CMD="python"
else
  fail "Python not found — install Python 3.6+"
fi

# 1. Check auth type is qwen-oauth
if [[ -f "$QWEN_DIR/settings.json" ]]; then
  AUTH_TYPE=$($PYTHON_CMD -c "
import json
d = json.load(open('$QWEN_DIR/settings.json'))
print(d.get('security',{}).get('auth',{}).get('selectedType', 'none'))
" 2>/dev/null || echo "none")

  if [[ "$AUTH_TYPE" == "qwen-oauth" ]]; then
    pass "Auth: qwen-oauth (free tier — 1,000 req/day)"
  else
    warn "Auth type is '$AUTH_TYPE' (expected 'qwen-oauth' for free tier)"
  fi
else
  fail "settings.json not found at ~/.qwen/settings.json"
fi

# 2. Check modelProviders configured correctly
if [[ -f "$QWEN_DIR/settings.json" ]]; then
  PROVIDER_INFO=$($PYTHON_CMD -c "
import json, sys
d = json.load(open('$QWEN_DIR/settings.json'))
providers = d.get('modelProviders', {})
qwen = providers.get('qwen-oauth', [])
if not qwen:
    sys.exit(1)
models = [m.get('id', '?') for m in qwen]
print(f'{len(qwen)} models: {', '.join(models)}')
" 2>/dev/null)

  if [[ -n "$PROVIDER_INFO" ]]; then
    pass "modelProviders: $PROVIDER_INFO"
  else
    warn "modelProviders has no qwen-oauth entries"
  fi
fi

# 3. Check oh-my-qwen.json helper config
if [[ -f "$QWEN_DIR/oh-my-qwen.json" ]]; then
  if $PYTHON_CMD -c "import json; json.load(open('$QWEN_DIR/oh-my-qwen.json'))" 2>/dev/null; then
    pass "oh-my-qwen.json valid"
    AGENT_COUNT=$($PYTHON_CMD -c "import json; d=json.load(open('$QWEN_DIR/oh-my-qwen.json')); print(len(d.get('agents',{})))" 2>/dev/null || echo 0)
    pass "$AGENT_COUNT agents configured"
  else
    fail "oh-my-qwen.json has invalid JSON"
  fi
else
  warn "oh-my-qwen.json not found (optional helper config)"
fi

# 4. Check subagents
AGENT_DIR="$QWEN_DIR/agents"
EXPECTED_AGENTS=("sisyphus" "prometheus" "hephaestus" "atlas" "explore" "librarian" "oracle" "metis" "momus" "multimodal-looker" "code-reviewer" "testing-expert")
FOUND_AGENTS=()

if [[ -d "$AGENT_DIR" ]]; then
  for agent in "${EXPECTED_AGENTS[@]}"; do
    if [[ -f "$AGENT_DIR/$agent.md" ]]; then
      if head -1 "$AGENT_DIR/$agent.md" | grep -q "^---"; then
        FOUND_AGENTS+=("$agent")
      else
        warn "$agent.md exists but missing YAML frontmatter"
      fi
    fi
  done

  if [[ ${#FOUND_AGENTS[@]} -eq ${#EXPECTED_AGENTS[@]} ]]; then
    pass "All ${#EXPECTED_AGENTS[@]} subagents installed"
  elif [[ ${#FOUND_AGENTS[@]} -gt 0 ]]; then
    warn "${#FOUND_AGENTS[@]}/${#EXPECTED_AGENTS[@]} subagents: ${FOUND_AGENTS[*]}"
  else
    fail "No subagents found in ~/.qwen/agents/"
  fi
else
  fail "Agents directory not found at ~/.qwen/agents"
fi

# 5. Check skills
SKILL_DIR="$QWEN_DIR/skills"
SKILLS=("ultrawork" "team-run" "code-review" "testing" "documentation" "git-master" "frontend-ui-ux" "ai-slop-remover")
INSTALLED_SKILLS=()

if [[ -d "$SKILL_DIR" ]]; then
  for skill in "${SKILLS[@]}"; do
    if [[ -f "$SKILL_DIR/$skill/SKILL.md" ]]; then
      INSTALLED_SKILLS+=("$skill")
    fi
  done

  if [[ ${#INSTALLED_SKILLS[@]} -eq ${#SKILLS[@]} ]]; then
    pass "All ${#SKILLS[@]} skills installed"
  elif [[ ${#INSTALLED_SKILLS[@]} -gt 0 ]]; then
    warn "${#INSTALLED_SKILLS[@]}/${#SKILLS[@]} skills: ${INSTALLED_SKILLS[*]}"
  else
    fail "No skills found"
  fi
else
  fail "Skills directory not found"
fi

# 6. Check state directory
if [[ -d "$HOME/.omg/state" ]]; then
  pass "State directory exists (~/.omg/state)"
else
  warn "State directory not found"
fi

# 7. Check scripts
SCRIPT_DIR="$QWEN_DIR/scripts"
if [[ -d "$SCRIPT_DIR" ]]; then
  SCRIPT_COUNT=$(find "$SCRIPT_DIR" -name "*.sh" -executable | wc -l)
  pass "$SCRIPT_COUNT executable scripts"
else
  warn "No scripts directory"
fi

# Summary
echo ""
echo "────────────────────────────────────────────────────────────"
echo -e "  ${GREEN}✓ $OK passed${NC}  ${YELLOW}⚠ $WARN warnings${NC}  ${RED}✗ $FAIL failed${NC}"
echo "────────────────────────────────────────────────────────────"

if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo -e "${RED}Some checks failed. Run:${NC}"
  echo "  bash ~/.qwen/scripts/oh-my-qwen-setup.sh"
  exit 1
fi

if [[ $WARN -gt 0 ]]; then
  echo ""
  echo -e "${YELLOW}Warnings detected. System is functional but could be improved.${NC}"
fi

echo ""
echo "oMoMoMoMo Ready! Include 'ultrawork' or 'ulw' in your prompt."
echo "12 agents • 8 skills • qwen-oauth free tier"
exit 0
