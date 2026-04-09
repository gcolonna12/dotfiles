#!/usr/bin/env bash

# Export and import Raycast settings (aliases, snippets, quicklinks, etc.)
# Raycast stores these in an encrypted database, so we use its native
# .rayconfig export format.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/raycast.rayconfig"

usage() {
    echo "Usage: $(basename "$0") <export|import>"
    echo ""
    echo "  export   Save current Raycast settings to dotfiles"
    echo "  import   Restore Raycast settings from dotfiles"
}

do_export() {
    echo "To export Raycast settings:"
    echo "  1. Open Raycast Settings (⌘ ,)"
    echo "  2. Go to Advanced"
    echo "  3. Click 'Export' under Data"
    echo "  4. Save the file as:"
    echo "     $CONFIG_FILE"
}

do_import() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "No config found at $CONFIG_FILE"
        echo "Run '$(basename "$0") export' on another machine first."
        exit 1
    fi

    echo "Opening Raycast import dialog..."
    open "$CONFIG_FILE"
}

case "${1:-}" in
    export)  do_export ;;
    import)  do_import ;;
    *)       usage; exit 1 ;;
esac
