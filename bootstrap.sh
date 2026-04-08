#!/usr/bin/env bash
# Bootstrap a new machine with packages.
# Usage:
#   bash bootstrap.sh          — core tools only (git, vim, tmux, fish, curl, wget)
#   bash bootstrap.sh full     — core + modern CLI replacements (eza, bat, fd, rg, starship, zoxide)
#
# Run install.sh afterwards to symlink all configs.

set -e

TIER="${1:-core}"
OS="$(uname -s)"

# --- macOS ---
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon installs to /opt/homebrew; Intel to /usr/local (already in PATH)
        [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    brew update && brew upgrade

    echo "=== Core ==="
    brew install git git-lfs vim tmux fish wget coreutils findutils gnu-sed grep

    if [ "$TIER" = "full" ]; then
        echo "=== Full ==="
        brew install eza bat fd ripgrep zoxide starship tldr tree
    fi

    # Set fish as default shell
    FISH_PATH="$(brew --prefix)/bin/fish"
    grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
    [ "$SHELL" != "$FISH_PATH" ] && chsh -s "$FISH_PATH"

    brew cleanup

# --- Linux (Debian/Ubuntu only) ---
elif [ "$OS" = "Linux" ]; then
    if ! command -v apt-get &>/dev/null; then
        echo "This script only supports Debian/Ubuntu. Install packages manually."
        exit 1
    fi

    # Install packages one at a time — skip gracefully if unavailable (ARM/RISC-V gaps),
    # but surface real apt errors (network failures, locked dpkg, etc.)
    apt_install() {
        for pkg in "$@"; do
            if apt-cache show "$pkg" &>/dev/null 2>&1; then
                sudo apt-get install -y --no-install-recommends "$pkg"
                echo "  Installed: $pkg"
            else
                echo "  Skipped (not in apt): $pkg"
            fi
        done
    }

    sudo apt-get update -qq

    echo "=== Core ==="
    apt_install git vim tmux fish curl wget openssh-client

    if [ "$TIER" = "full" ]; then
        echo "=== Full ==="
        apt_install bat fd-find ripgrep zoxide tldr

        # eza: try apt first, fall back to cargo
        if apt-cache show eza &>/dev/null 2>&1; then
            sudo apt-get install -y --no-install-recommends eza
            echo "  Installed: eza"
        elif command -v cargo &>/dev/null; then
            echo "  Installing eza via cargo..."
            cargo install eza
        else
            echo "  eza not available — skipping (ls will be used)"
        fi

        # Ubuntu installs bat as `batcat` and fd as `fdfind` — symlink to the expected names.
        # ~/bin is added to PATH by install.sh; re-open your shell after running install.sh.
        mkdir -p "$HOME/bin"
        if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
            ln -sf "$(command -v batcat)" "$HOME/bin/bat"
            echo "  Linked batcat -> ~/bin/bat"
        fi
        if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
            ln -sf "$(command -v fdfind)" "$HOME/bin/fd"
            echo "  Linked fdfind -> ~/bin/fd"
        fi

        # Starship — not in apt, use the official installer
        if ! command -v starship &>/dev/null; then
            echo "  Installing Starship..."
            curl -sSf https://starship.rs/install.sh | sh -s -- --yes
        fi
    fi

    # Set fish as default shell.
    # chsh may require a password interactively — make failure advisory, not fatal.
    set +e
    FISH_PATH="$(command -v fish)"
    grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
    if [ "$SHELL" != "$FISH_PATH" ]; then
        chsh -s "$FISH_PATH" \
            && echo "Default shell set to fish. Re-login to apply." \
            || echo "  Could not set default shell automatically. Run: chsh -s $FISH_PATH"
    fi
    set -e

else
    echo "Unsupported OS: $OS"
    exit 1
fi

echo ""
echo "Done. Run: bash install.sh"
