#!/usr/bin/env bash
# oh-my-qwen model-resolution — show effective model for each agent/category
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

CONFIG="$HOME/.qwen/oh-my-qwen.json"
SETTINGS="$HOME/.qwen/settings.json"

echo -e "${CYAN} oMoMoMoMo Model Resolution${NC}"
echo ""

# Model Providers from settings.json
echo -e "${GREEN}── Model Providers (settings.json) ───────────────${NC}"
if [[ -f "$SETTINGS" ]]; then
  python3 -c "
import json
settings = json.load(open('$SETTINGS'))
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

  python3 -c "
import json
config = json.load(open('$CONFIG'))
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

  python3 -c "
import json
config = json.load(open('$CONFIG'))
for name, cat in config.get('categories', {}).items():
    model = cat.get('model', 'N/A').replace('qwen/', '')
    fallback = ' → '.join(f.replace('qwen/', '') for f in cat.get('fallback', ['(none)']))
    print(f'  {name:<20} {model:<30} {fallback}')
" 2>/dev/null
fi
