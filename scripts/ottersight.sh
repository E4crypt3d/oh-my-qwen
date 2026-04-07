#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

QWEN_DIR="$HOME/.qwen"

check_prereq() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name found"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name not found"
        return 1
    fi
}

echo -e "${CYAN} OtterSight Security Scanner Setup ${NC}"
echo ""

echo "Checking prerequisites..."
check_prereq syft "Syft" || MISSING+=("Syft")
check_prereq grype "Grype" || MISSING+=("Grype")

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}Missing prerequisites. Install with:${NC}"
    echo ""
    echo "  macOS:"
    echo "    brew install anchore/syft/syft anchore/grype/grype"
    echo ""
    echo "  Linux:"
    echo "    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh"
    echo "    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh"
    echo ""
    echo "  Windows (PowerShell):"
    echo "    scoop install syft grype"
    echo ""
    echo "Or use Docker: docker run --rm -v \$(pwd):/repo ghcr.io/ottersight/cli scan ."
    exit 1
fi

echo ""
echo -e "${GREEN}All prerequisites installed!${NC}"
echo ""

read -p "Add OtterSight MCP to Qwen Code? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 -c "
import json
settings_path = '$QWEN_DIR/settings.json'
with open(settings_path) as f:
    settings = json.load(f)

if 'mcpServers' not in settings:
    settings['mcpServers'] = {}

settings['mcpServers']['ottersight'] = {
    'command': 'npx',
    'args': ['-y', '@ottersight/mcp']
}

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
    echo -e "${GREEN}✓${NC} OtterSight MCP added to settings.json"
    echo ""
    echo "Restart Qwen Code and run /mcp to verify."
else
    echo "Skipped. Run this script anytime to add OtterSight."
fi