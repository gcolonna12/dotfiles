# nix — work-specific

> ⚠️ **Work config.** Everything here supports a Nix/direnv workflow tied to a
> private binary cache and a GitLab netrc. It's isolated in this directory so
> it's easy to drop if the job changes. None of it loads on a machine without
> Nix installed.

The private cache URL, its public key, and the netrc are machine-specific and
are **not** tracked. See the setup steps below.

## Files (symlinked by `install.sh`)

| Repo file            | Symlinked to                   | Purpose |
|----------------------|--------------------------------|---------|
| `direnvrc`           | `~/.config/direnv/direnvrc`    | Sources **nix-direnv** and relocates its cache to a global location. This is what makes `use flake` fast and what fixes the VS Code direnv plugin. |
| `direnv-config.toml` | `~/.config/direnv/config.toml` | Silences direnv's slow-eval timeout warning and per-`cd` env diff. |

## Copied templates (edit after install, never tracked)

| Template               | Copied to                | Purpose |
|------------------------|--------------------------|---------|
| `user-nix.conf.example`| `~/.config/nix/nix.conf` | Adds a private cachix substituter + public key. Fill in the cache name/key. |

## NOT tracked (machine-specific / secret — set up by hand)

- `~/.config/nix/netrc` and `/etc/nix/netrc` — contain the GitLab token. Recreate
  per your team's netrc instructions. Update whenever the GitLab PAT expires.
- `/etc/nix/nix.conf` — root-owned, written by the Nix installer. Optionally add
  `warn-dirty = false` there manually.
- `~/.config/cachix/cachix.dhall` — written by `cachix authtoken <TOKEN>`.

## One-time setup on a new machine

```sh
# 1. Install Nix (flakes-enabled), then nix-direnv + nixd:
nix profile add nixpkgs#nix-direnv nixpkgs#nixd

# 2. Cachix (get added to the cache by an admin first):
nix profile add --accept-flake-config nixpkgs#cachix
cachix authtoken <TOKEN>
cachix use <your-cache>

# 3. Create the netrc, then run install.sh to symlink this dir and copy the
#    user-nix.conf template. Edit ~/.config/nix/nix.conf with your cache details.
```

## Per-project: stop typing `nix develop`

Drop a `.envrc` at a repo root, then `direnv allow` once. After that, `cd`-ing
into the repo auto-loads (and `cd`-ing out auto-unloads) the dev shell:

```sh
echo 'use flake' > .envrc
direnv allow
```
