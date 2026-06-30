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
mkdir -p "$HOME/.config/fish/completions"
for f in "$DOTFILES_DIR"/fish/completions/*.fish; do
    [ -e "$f" ] || continue
    link "$f" "$HOME/.config/fish/completions/$(basename "$f")"
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

# TPM (Tmux Plugin Manager) — required by the @plugin lines in .tmux.conf.
# Clone if missing, then install/update plugins headlessly so a fresh machine
# doesn't need `prefix + I` to bring up tmux-resurrect, tmux-agent-indicator, etc.
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
if command -v tmux &>/dev/null; then
    # install_plugins needs a running server with the config loaded, otherwise
    # TMUX_PLUGIN_MANAGER_PATH is unset and it aborts. Use a throwaway session.
    tmux new-session -d -s _tpm_install
    tmux source-file "$HOME/.tmux.conf"
    "$TPM_DIR/bin/install_plugins" >/dev/null && echo "Installed tmux plugins"
    tmux kill-session -t _tpm_install
fi

echo ""
echo "=== EditorConfig ==="
link "$DOTFILES_DIR/editorconfig/.editorconfig" "$HOME/.editorconfig"

echo ""
echo "=== Claude Code ==="
mkdir -p "$HOME/.claude"
link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link "$DOTFILES_DIR/claude/gh-api-readonly-guard.sh" "$HOME/.claude/gh-api-readonly-guard.sh"

# Skills: link each skill folder under dotfiles/claude/skills/ into ~/.claude/skills/.
# Per-skill symlinks (not the whole skills/ dir) so locally-installed skills can
# coexist alongside dotfiles-managed ones.
mkdir -p "$HOME/.claude/skills"
if [ -d "$DOTFILES_DIR/claude/skills" ]; then
    for skill_dir in "$DOTFILES_DIR"/claude/skills/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        link "$DOTFILES_DIR/claude/skills/$skill_name" "$HOME/.claude/skills/$skill_name"
    done
fi

# settings.json is compiled (not symlinked): base from repo, deep-merged with
# ~/.claude/settings.local.json (machine-specific, e.g. Bedrock/AWS env vars).
# Claude Code has no native settings.local.json at the user scope, so we merge
# at install time. Re-run install.sh after editing either file.
copy_template "$DOTFILES_DIR/claude/settings.local.json.example" "$HOME/.claude/settings.local.json"
if command -v jq &>/dev/null; then
    if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
        cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.backup"
        echo "Backed up existing $HOME/.claude/settings.json to settings.json.backup"
    fi
    # `*` deep-merges, but it REPLACES arrays — so a local overlay listing even
    # one permission would wipe the base allow/deny/ask lists. Union + dedupe the
    # permission arrays explicitly so local entries add to the base, not replace.
    jq -s '
        .[0] as $base | .[1] as $local
        | reduce (["allow","deny","ask"][]) as $k ($base * $local;
            (((($base.permissions[$k]) // []) + (($local.permissions[$k]) // [])) | unique) as $u
            | if ($u | length) > 0 then .permissions[$k] = $u else . end)
    ' \
        "$DOTFILES_DIR/claude/settings.json" \
        "$HOME/.claude/settings.local.json" \
        > "$HOME/.claude/settings.json.tmp" \
        && mv "$HOME/.claude/settings.json.tmp" "$HOME/.claude/settings.json"
    echo "Compiled $HOME/.claude/settings.json (base + local overlay)"
else
    echo "Warning: jq not installed — copying base settings.json without local overlay"
    cp "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
fi
# These settings must live in ~/.claude.json (runtime config, not symlinkable).
# Merge them in without clobbering existing keys.
if command -v jq &>/dev/null && [ -f "$HOME/.claude.json" ]; then
    jq '.teammateMode = "auto" | .autoConnectIde = true' "$HOME/.claude.json" > "$HOME/.claude.json.tmp" \
        && mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
    echo "Set teammateMode=auto, autoConnectIde=true in ~/.claude.json"
elif command -v jq &>/dev/null; then
    echo '{"teammateMode":"auto","autoConnectIde":true}' > "$HOME/.claude.json"
    echo "Created ~/.claude.json with teammateMode=auto, autoConnectIde=true"
else
    echo "Warning: jq not installed — set teammateMode/autoConnectIde manually in ~/.claude.json"
fi

echo ""
echo "=== iTerm2 ==="
if [ "$(uname -s)" = "Darwin" ]; then
    link "$DOTFILES_DIR/iterm2/profiles.json" \
        "$HOME/Library/Application Support/iTerm2/DynamicProfiles/everforest.json"
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
fi

echo ""
echo "=== VS Code ==="
if [ "$(uname -s)" = "Darwin" ]; then
    link "$DOTFILES_DIR/vscode/settings.json" \
        "$HOME/Library/Application Support/Code/User/settings.json"
else
    link "$DOTFILES_DIR/vscode/settings.json" \
        "$HOME/.config/Code/User/settings.json"
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
echo "=== Nix (Generative-specific) ==="
# Company config — only relevant on machines with Nix. The actual netrc (with the
# GitLab token) and /etc/nix/nix.conf are set up by hand per the internal docs;
# we only symlink the secret-free user configs. See nix/README.md.
if command -v nix &>/dev/null; then
    link "$DOTFILES_DIR/nix/direnvrc" "$HOME/.config/direnv/direnvrc"
    link "$DOTFILES_DIR/nix/direnv-config.toml" "$HOME/.config/direnv/config.toml"
    link "$DOTFILES_DIR/nix/user-nix.conf" "$HOME/.config/nix/nix.conf"
else
    echo "Nix not installed — skipping"
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
