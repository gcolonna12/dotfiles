#!/usr/bin/env bash

# Symlink dotfiles to their expected locations.
# Symlinks mean edits to the repo files take effect immediately —
# no need to re-run this script after every change.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1"
    local dst="$2"

    # Back up existing files that aren't already symlinks to our repo
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "Backing up existing $dst to ${dst}.backup"
        mv "$dst" "${dst}.backup"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "Linked $dst -> $src"
}

# Copy a .example template to its target (skip if target already exists).
# These contain machine-specific values (secrets, identity, keys) that
# must be edited after install — they're never symlinked.
copy_template() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"
    if [ ! -e "$dst" ]; then
        cp "$src" "$dst"
        echo "Copied $(basename "$src") -> $dst"
        TEMPLATES_COPIED+=("$dst")
    else
        echo "$dst already exists — skipping"
    fi
}

TEMPLATES_COPIED=()

echo "=== Fish shell ==="
link "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
# Fish auto-loads everything in conf.d/ and functions/
for f in "$DOTFILES_DIR"/fish/conf.d/*.fish; do
    link "$f" "$HOME/.config/fish/conf.d/$(basename "$f")"
done
for f in "$DOTFILES_DIR"/fish/functions/*.fish; do
    link "$f" "$HOME/.config/fish/functions/$(basename "$f")"
done
copy_template "$DOTFILES_DIR/fish/conf.d/extra.fish.example" "$HOME/.config/fish/conf.d/extra.fish"

echo ""
echo "=== Zsh (fallback shell) ==="
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
# Modular zsh configs go in ~/.zsh/
mkdir -p "$HOME/.zsh"
for f in exports aliases functions; do
    [ -f "$DOTFILES_DIR/zsh/$f" ] && link "$DOTFILES_DIR/zsh/$f" "$HOME/.zsh/$f"
done
copy_template "$DOTFILES_DIR/zsh/extra.example" "$HOME/.zsh/extra"

echo ""
echo "=== Starship prompt ==="
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "=== SSH ==="
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
copy_template "$DOTFILES_DIR/ssh/config.example" "$HOME/.ssh/config"
[ -e "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"

echo ""
echo "=== Git ==="
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore"
copy_template "$DOTFILES_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"

echo ""
echo "=== Vim ==="
link "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
# Vim needs these directories for centralized swap/backup/undo files
mkdir -p "$HOME/.vim/backups" "$HOME/.vim/swaps" "$HOME/.vim/undo"

echo ""
echo "=== Readline ==="
link "$DOTFILES_DIR/readline/.inputrc" "$HOME/.inputrc"

echo ""
echo "=== curl ==="
link "$DOTFILES_DIR/curl/.curlrc" "$HOME/.curlrc"

echo ""
echo "=== wget ==="
link "$DOTFILES_DIR/wget/.wgetrc" "$HOME/.wgetrc"

echo ""
echo "=== tmux ==="
link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo ""
echo "=== EditorConfig ==="
link "$DOTFILES_DIR/editorconfig/.editorconfig" "$HOME/.editorconfig"

echo ""
echo "=== Claude Code ==="
mkdir -p "$HOME/.claude"
link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

echo ""
echo "=== iTerm2 ==="
if [ "$(uname -s)" = "Darwin" ]; then
    link "$DOTFILES_DIR/iterm2/profiles.json" \
        "$HOME/Library/Application Support/iTerm2/DynamicProfiles/everforest.json"
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
fi

echo ""
echo "=== Hushlogin ==="
link "$DOTFILES_DIR/hushlogin/.hushlogin" "$HOME/.hushlogin"

echo ""
echo "=== Raycast ==="
if [ "$(uname -s)" = "Darwin" ] && [ -f "$DOTFILES_DIR/raycast/raycast.rayconfig" ]; then
    echo "Raycast config found — opening import dialog..."
    open "$DOTFILES_DIR/raycast/raycast.rayconfig"
else
    echo "Skipped (macOS-only; run 'raycast/sync.sh export' to save config)"
fi

echo ""
echo "=== ~/bin ==="
# Symlink the entire bin directory so custom scripts are on PATH
if [ -d "$DOTFILES_DIR/bin" ] && [ "$(ls -A "$DOTFILES_DIR/bin")" ]; then
    for f in "$DOTFILES_DIR"/bin/*; do
        link "$f" "$HOME/bin/$(basename "$f")"
    done
fi

echo ""
echo "Done!"
if [ ${#TEMPLATES_COPIED[@]} -gt 0 ]; then
    echo ""
    echo "Templates copied (edit these with your details):"
    for t in "${TEMPLATES_COPIED[@]}"; do
        echo "  - $t"
    done
fi
echo ""
echo "Next steps:"
echo "  1. Generate SSH key if needed:  ssh-keygen -t ed25519"
echo "  2. Open a new terminal or run 'exec fish' to apply changes."
