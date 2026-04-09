# dotfiles

Personal dotfiles for macOS and Linux with **fish** (default shell), **zsh** (fallback), and **Starship** prompt.

Inspired by [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles).

## Setup on a new machine

### macOS

```bash
# 1. Clone the repo
git clone https://github.com/gcolonna12/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install packages
bash bootstrap.sh        # core tools only
bash bootstrap.sh full   # core + modern CLI tools + GUI apps

# 3. Symlink all configs
bash install.sh

# 4. Apply macOS system defaults (then reboot)
bash macos/.macos
```

### Linux (Debian/Ubuntu) — server or edge device

```bash
# 1. Clone the repo
git clone https://github.com/gcolonna12/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install packages
bash bootstrap.sh        # core tools only
bash bootstrap.sh full   # core + modern CLI tools

# 3. Symlink all configs
bash install.sh
```

The `full` tier is optional — configs detect installed tools automatically and fall back to
system defaults when they're absent. On constrained devices (small RAM, limited storage),
`core` is enough to be productive.

### What gets installed

**Core** — the essentials:

| Package | Description |
|---|---|
| [git](https://git-scm.com/) | Version control |
| [git-lfs](https://git-lfs.com/) | Large file storage for git (macOS only) |
| [vim](https://www.vim.org/) | Text editor |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [fish](https://fishshell.com/) | Default shell |
| [curl](https://curl.se/) / [wget](https://www.gnu.org/software/wget/) | HTTP clients |
| [coreutils](https://www.gnu.org/software/coreutils/), [findutils](https://www.gnu.org/software/findutils/), [gnu-sed](https://www.gnu.org/software/sed/), [grep](https://www.gnu.org/software/grep/) | GNU versions of macOS built-ins (macOS only) |

**Full** — modern CLI replacements:

| Package | Description |
|---|---|
| [eza](https://eza.rocks/) | Modern `ls` replacement with git integration |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [fd](https://github.com/sharkdp/fd) | Fast `find` alternative |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` alternative |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` that learns your habits |
| [starship](https://starship.rs/) | Cross-shell prompt |
| [tlrc](https://github.com/tldr-pages/tlrc) / [tldr](https://tldr.sh/) | Simplified man pages |
| [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) | Directory tree viewer (macOS only) |

**Full** also installs GUI apps on macOS:

| App | Description |
|---|---|
| [iTerm2](https://iterm2.com/) | Terminal emulator |
| [Claude Code](https://claude.ai/code) | AI coding assistant |
| [Raycast](https://www.raycast.com/) | Launcher and productivity tool |
| [Stats](https://github.com/exelban/stats) | Menu bar system monitor |

## Post-install setup

### Git identity

Git user info and profile switching are machine-specific:

```bash
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
# Edit with your name, email, credential helper, and any includeIf profile overrides
```

### Secrets

Tokens and passwords live in git-ignored files, never in this repo:

```bash
cp ~/dotfiles/zsh/extra.example ~/.zsh/extra
cp ~/dotfiles/fish/conf.d/extra.fish.example ~/.config/fish/conf.d/extra.fish
```

### SSH keys

The SSH config is included, but keys must be generated per machine:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
ssh-add ~/.ssh/id_ed25519
# Copy ~/.ssh/id_ed25519.pub to GitHub → Settings → SSH keys
```

For multiple GitHub accounts, uncomment the `github-work` host in `ssh/config` and point it at a second key.

## What's included

| Directory | What it configures |
|---|---|
| `fish/` | Fish shell — config, aliases, exports, and functions |
| `zsh/` | Zsh fallback — .zshrc, modular aliases/exports/functions |
| `starship/` | Cross-shell prompt with git status, command duration, etc. |
| `git/` | Git aliases, branch sorting, global ignore, color scheme |
| `vim/` | Vim with Everforest, clipboard integration, line numbers |
| `tmux/` | Terminal multiplexer with Ctrl+A prefix, mouse support |
| `readline/` | Better history search and completion in Python REPL, psql, etc. |
| `curl/` | Sensible timeouts and auto-referer |
| `wget/` | Sensible timeouts, retries, and timestamping |
| `editorconfig/` | 2-space indent, UTF-8, LF line endings, trim trailing whitespace |
| `ssh/` | SSH client config with GitHub account setup |
| `claude/` | Claude Code settings and project instructions |
| `iterm2/` | Everforest color theme (macOS only) |
| `raycast/` | Aliases, snippets, and settings via export/import (macOS only) |
| `macos/` | macOS defaults — Finder, Dock, screenshots, dev-friendly settings |
| `bin/` | Personal scripts available on `$PATH` |

## How it works

`install.sh` creates **symlinks** from this repo to your home directory. That means:

- Editing files in this repo takes effect immediately (no re-running the installer)
- `git diff` shows exactly what changed in your config
- Existing files are backed up to `*.backup` before being replaced

## Adding new configs

1. Create the config file in the appropriate directory
2. Add a `link` call in `install.sh`
3. Re-run `bash install.sh`

## Shell structure

**Fish** (default) auto-loads files from:
- `conf.d/` — aliases and exports (sourced automatically)
- `functions/` — one file per function (lazy-loaded automatically)

**Zsh** (fallback) sources modular files from `~/.zsh/`:
- `exports`, `aliases`, `functions`, `extra` (git-ignored, for secrets/machine-specific config)
