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

echo "=== Fish shell ==="
link "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
# Fish auto-loads everything in conf.d/ and functions/
for f in "$DOTFILES_DIR"/fish/conf.d/*.fish; do
    link "$f" "$HOME/.config/fish/conf.d/$(basename "$f")"
done
for f in "$DOTFILES_DIR"/fish/functions/*.fish; do
    link "$f" "$HOME/.config/fish/functions/$(basename "$f")"
done

echo ""
echo "=== Zsh (fallback shell) ==="
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
# Modular zsh configs go in ~/.zsh/
mkdir -p "$HOME/.zsh"
for f in exports aliases functions; do
    [ -f "$DOTFILES_DIR/zsh/$f" ] && link "$DOTFILES_DIR/zsh/$f" "$HOME/.zsh/$f"
done

echo ""
echo "=== Starship prompt ==="
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "=== SSH ==="
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
# Copied not symlinked — SSH config contains machine-specific keys and hosts.
# Use ssh/config.example as a starting point.
if [ ! -e "$HOME/.ssh/config" ]; then
    cp "$DOTFILES_DIR/ssh/config.example" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    echo "Copied ssh/config.example -> ~/.ssh/config (edit with your keys)"
else
    echo "~/.ssh/config already exists — skipping (check ssh/config.example for updates)"
fi

echo ""
echo "=== Git ==="
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore"

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
# CLAUDE.md can be symlinked — Claude reads it but doesn't write to it
link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
# settings.json gets COPIED not symlinked — Claude Code writes to it at runtime,
# and a symlink would push runtime state back into the repo
if [ ! -e "$HOME/.claude/settings.json" ]; then
    cp "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
    echo "Copied settings.json (merge settings.local.example for machine-specific config)"
else
    echo "~/.claude/settings.json already exists — skipping (check claude/settings.json for updates)"
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
echo "Done! Next steps:"
echo "  1. cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local  (set your git identity)"
echo "  2. cp ~/dotfiles/zsh/extra.example ~/.zsh/extra                   (add secrets/tokens)"
echo "  3. Generate SSH key if needed:  ssh-keygen -t ed25519"
echo "  4. Open a new terminal or run 'exec fish' to apply changes."
