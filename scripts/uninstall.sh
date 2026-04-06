#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

QWEN_DIR="$HOME/.qwen"
BACKUP_DIR="$QWEN_DIR/.backup"

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

echo -e "${CYAN}"
echo " oMoMoMoMo oh-my-qwen uninstaller"
echo -e "${NC}"

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo -e "${YELLOW}No backup directory found. Nothing to restore.${NC}"
  echo "Running standard uninstall..."
fi

RESTORED=0

restore_backup() {
    local rel_path="$1"
    local backup_path="$BACKUP_DIR/$rel_path"
    local target_path="$QWEN_DIR/$rel_path"
    
    if [[ -f "$backup_path" ]]; then
        mkdir -p "$(dirname "$target_path")"
        cp "$backup_path" "$target_path"
        info "Restored: $rel_path"
        RESTORED=$((RESTORED + 1))
    fi
}

if [[ -d "$BACKUP_DIR" ]]; then
    info "Restoring backed up files..."
    for f in "$BACKUP_DIR"/*; do
        [[ -f "$f" ]] || continue
        rel_path="${f#$BACKUP_DIR/}"
        restore_backup "$rel_path"
    done
    
    for f in "$BACKUP_DIR"/*/*; do
        [[ -f "$f" ]] || continue
        rel_path="${f#$BACKUP_DIR/}"
        restore_backup "$rel_path"
    done
    
    for f in "$BACKUP_DIR"/*/*/*; do
        [[ -f "$f" ]] || continue
        rel_path="${f#$BACKUP_DIR/}"
        restore_backup "$rel_path"
    done
    
    pass "$RESTORED files restored"
    
    info "Removing backup directory..."
    rm -rf "$BACKUP_DIR"
fi

info "Removing oh-my-qwen installed files..."
rm -rf "$QWEN_DIR/agents" 2>/dev/null && pass "Removed agents/" || true
rm -rf "$QWEN_DIR/skills" 2>/dev/null && pass "Removed skills/" || true
rm -rf "$QWEN_DIR/scripts" 2>/dev/null && pass "Removed scripts/" || true
rm -f "$QWEN_DIR/oh-my-qwen.json" 2>/dev/null && pass "Removed oh-my-qwen.json" || true
rm -f "$QWEN_DIR/QWEN.md" 2>/dev/null && pass "Removed QWEN.md" || true
rm -rf "$HOME/.omg" 2>/dev/null && pass "Removed ~/.omg/" || true

echo ""
echo "┌─ Uninstall Complete ──────────────────────────────────────────┐"
echo "│                                                               │"
echo "│  Original files restored from backup                        │"
echo "│  oh-my-qwen files removed                                    │"
echo "│                                                               │"
echo "│  Your settings.json is preserved.                            │"
echo "│  To fully reset Qwen Code, remove it manually:               │"
echo "│    rm ~/.qwen/settings.json                                  │"
echo "│                                                               │"
echo "└───────────────────────────────────────────────────────────────┘"