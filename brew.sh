#!/usr/bin/env bash

# Install Homebrew packages for a new machine.
# Run: bash brew.sh

# Homebrew isn't pre-installed on macOS — install it first if missing
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrew on Apple Silicon installs to /opt/homebrew, not /usr/local
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

brew update
brew upgrade

# Fish shell — our default shell
brew install fish

# Starship prompt — one config for both fish and zsh
brew install starship

# Git with latest features (macOS ships an older version)
brew install git
# Large file storage — needed for repos with binary assets
brew install git-lfs

# vim — our $EDITOR for git commits, SSH sessions, etc.
brew install vim

# GNU coreutils replaces macOS's outdated BSD versions of ls, cat, sort, etc.
# Installed as g-prefixed (gls, gcat, etc.) to avoid breaking system scripts
brew install coreutils

# GNU find/xargs — supports features like -regex and -print0 that macOS find lacks
brew install findutils

# GNU sed — macOS sed requires -i '' (with empty string) while GNU sed uses -i
# without args, causing scripts to break across platforms
brew install gnu-sed

# GNU grep — supports -P (Perl regex) which macOS grep doesn't
brew install grep

# Wget — we have a .wgetrc configured for it
brew install wget

# tmux — terminal multiplexer for persistent sessions on remote servers
brew install tmux

# tree — used by our `tre` shell function
brew install tree

# --- Modern replacements for classic Unix tools ---

# tldr — community-maintained help pages, way more readable than man pages
# tlrc is the Rust client — faster and actively maintained (the original `tldr` is deprecated in Homebrew)
brew install tlrc

# zoxide — learns your most-used directories, `z foo` jumps to ~/projects/foo
brew install zoxide

# eza — ls replacement with git integration, icons, and sane defaults
brew install eza

# bat — cat with syntax highlighting, line numbers, and git diff markers
brew install bat

# fd — find replacement with intuitive syntax: `fd pattern` instead of `find . -name '*pattern*'`
brew install fd

# ripgrep — grep replacement, 10-100x faster, respects .gitignore by default
brew install ripgrep

# uv — fast Python package manager that also handles Python version management
brew install uv

# --- Non-Homebrew tools ---

# SDKMAN — JDK, Gradle, Maven version manager. Not in Homebrew, has its own installer.
if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
fi

# --- Fish plugin manager + plugins ---

# Fisher — plugin manager for fish. Install it from bash by shelling into fish.
BREW_PREFIX=$(brew --prefix)
if [ ! -f "$HOME/.config/fish/functions/fisher.fish" ]; then
    echo "Installing Fisher (fish plugin manager)..."
    "${BREW_PREFIX}/bin/fish" -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fi

# SDKMAN bridge for fish — makes `sdk` commands work in fish
"${BREW_PREFIX}/bin/fish" -c 'fisher install reitzig/sdkman-for-fish'

# Set fish as the default shell
if ! grep -q "${BREW_PREFIX}/bin/fish" /etc/shells; then
    echo "${BREW_PREFIX}/bin/fish" | sudo tee -a /etc/shells
    chsh -s "${BREW_PREFIX}/bin/fish"
fi

brew cleanup
