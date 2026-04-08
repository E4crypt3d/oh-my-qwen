#!/usr/bin/env bash
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

CONFIG="$HOME/.qwen/oh-my-qwen.json"
SETTINGS="$HOME/.qwen/settings.json"

PYTHON_CMD=""
for candidate in "python3" "python" "py -3" "/c/Windows/py.exe -3" "py.exe -3"; do
  if eval "$candidate -c 'import sys; sys.exit(0)'" >/dev/null 2>&1; then
    PYTHON_CMD="$candidate"
    break
  fi
done

if [[ -z "$PYTHON_CMD" ]]; then
  echo "Error: Python not found (install Python 3.6+ or ensure 'py -3' works)"
  exit 1
fi

echo -e "${CYAN} oMoMoMoMo Model Resolution${NC}"
echo ""

# Model Providers from settings.json
echo -e "${GREEN}── Model Providers (settings.json) ───────────────${NC}"
if [[ -f "$SETTINGS" ]]; then
  $PYTHON_CMD -c "
import json, os
settings = json.load(open(os.path.expanduser('~/.qwen/settings.json')))
providers = settings.get('modelProviders', {})
for auth_type, models in providers.items():
    print(f'  [{auth_type}]')
    for m in models:
        name = m.get('name', m.get('id', '?'))
        desc = m.get('description', '')
        if desc:
            desc = f' — {desc[:50]}'
        print(f'    • {name}{desc}')
    print()
" 2>/dev/null || echo "  (could not parse settings.json)"
fi

# Agent model assignments
echo -e "${GREEN}── Agent Model Assignments ───────────────────────${NC}"
if [[ -f "$CONFIG" ]]; then
  printf "  %-20s %-30s %s\n" "AGENT" "MODEL" "ROLE"
  printf "  %-20s %-30s %s\n" "────────────────────" "──────────────────────────────" "──────────────────"

  $PYTHON_CMD -c "
import json, os
config = json.load(open(os.path.expanduser('~/.qwen/oh-my-qwen.json')))
for name, agent in config.get('agents', {}).items():
    model = agent.get('model', 'N/A').replace('qwen/', '')
    desc = agent.get('description', '')[:30]
    print(f'  {name:<20} {model:<30} {desc}')
" 2>/dev/null
fi

# Category fallbacks
echo ""
echo -e "${GREEN}── Category Fallback Chains ──────────────────────${NC}"
if [[ -f "$CONFIG" ]]; then
  printf "  %-20s %-30s %s\n" "CATEGORY" "PRIMARY" "FALLBACK CHAIN"
  printf "  %-20s %-30s %s\n" "────────────────────" "──────────────────────────────" "──────────────────"

  $PYTHON_CMD -c "
import json, os
config = json.load(open(os.path.expanduser('~/.qwen/oh-my-qwen.json')))
for name, cat in config.get('categories', {}).items():
    model = cat.get('model', 'N/A').replace('qwen/', '')
    fallback = ' → '.join(f.replace('qwen/', '') for f in cat.get('fallback', ['(none)']))
    print(f'  {name:<20} {model:<30} {fallback}')
" 2>/dev/null
fi
