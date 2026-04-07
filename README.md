# dotfiles

Personal dotfiles for macOS with **fish** (default shell), **zsh** (fallback), **iTerm2**, and **Starship** prompt.

Inspired by [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles).

## Setup on a new machine

```bash
# 1. Clone the repo
git clone https://github.com/gcolonna12/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install Homebrew packages (installs Homebrew itself if missing)
bash brew.sh

# 3. Symlink all configs to their expected locations
bash install.sh

# 4. Apply macOS system defaults (then reboot)
bash macos/.macos
```

## Post-install setup

### Git identity

Git user info and profile switching are machine-specific:

```bash
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
# Edit with your name, email, and any includeIf profile overrides
```

### Secrets

Tokens and passwords live in git-ignored files, never in this repo:

```bash
cp ~/dotfiles/zsh/extra.example ~/.zsh/extra
cp ~/dotfiles/fish/conf.d/extra.fish.example ~/.config/fish/conf.d/extra.fish
```

### SSH keys

The SSH config template is included, but keys must be generated per machine:

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
| `vim/` | Vim with Solarized Dark, clipboard integration, line numbers |
| `tmux/` | Terminal multiplexer with Ctrl+A prefix, mouse support |
| `readline/` | Better history search and completion in Python REPL, psql, etc. |
| `curl/` | Sensible timeouts and auto-referer |
| `wget/` | Sensible timeouts, retries, and timestamping |
| `editorconfig/` | 2-space indent, UTF-8, LF line endings, trim trailing whitespace |
| `iterm2/` | Solarized Dark color theme |
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
