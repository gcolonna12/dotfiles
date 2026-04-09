# Dotfiles

Shell config and dev tool setup for macOS and Linux.

## Scripts

- `bootstrap.sh` — installs packages (`core` or `full` tier)
- `install.sh` — symlinks configs to home directory

## Structure

Each topic gets its own directory. Files are symlinked by `install.sh` except:
- `ssh/config.example` — copied (machine-specific keys)

## Adding a new config

1. Create the file in a topic directory
2. Add a `link` call in `install.sh`

## Conventions

- Fish is the default shell; zsh is the fallback
- Configs auto-detect installed tools (`command -v` / `command -q`) and degrade gracefully
- Machine-specific secrets go in gitignored files (see `.example` templates)
- All shell scripts use `#!/usr/bin/env bash` and `set -e`
