# nix — Generative-specific

> ⚠️ **Company config.** Everything here is tied to my work at **Generative**
> (the private `generative-dev` cachix cache, the GitLab netrc, the base-flake
> tooling). It's isolated in this directory so it's easy to drop if I change
> jobs. None of it loads on a machine without Nix installed.

Source of truth: the internal
[Setup guide](https://generative.gitlab.io/team/documentation/technology/getting-started/setup.html)
(GitLab SSO). This directory implements its Nix/direnv section.

## Files (symlinked by `install.sh`)

| Repo file            | Symlinked to                   | Purpose |
|----------------------|--------------------------------|---------|
| `direnvrc`           | `~/.config/direnv/direnvrc`    | Sources **nix-direnv** and relocates its cache to a global location. This is what makes `use flake` fast and what fixes the VS Code direnv plugin. |
| `direnv-config.toml` | `~/.config/direnv/config.toml` | Silences direnv's slow-eval timeout warning and per-`cd` env diff. |
| `user-nix.conf`      | `~/.config/nix/nix.conf`       | Adds the `generative-dev` cachix substituter + public key. No secrets. |

## NOT tracked (machine-specific / secret — set up by hand per the docs)

- `~/.config/nix/netrc` and `/etc/nix/netrc` — contain the GitLab token. Recreate
  per the docs' netrc section. Update whenever the GitLab PAT expires.
- `/etc/nix/nix.conf` — root-owned, written by the Nix installer. The docs
  optionally add `warn-dirty = false` there; do that manually.
- `~/.config/cachix/cachix.dhall` — written by `cachix authtoken <TOKEN>`.

## One-time setup on a new machine

```sh
# 1. Install Nix (flakes-enabled), then nix-direnv + nixd:
nix profile add nixpkgs#nix-direnv nixpkgs#nixd

# 2. Cachix (get added to the cache by an admin first):
nix profile add --accept-flake-config nixpkgs#cachix
cachix authtoken <TOKEN>
cachix use generative-dev

# 3. Create the netrc (see docs), then run install.sh to symlink this dir.
```

## Per-project: stop typing `nix develop`

Drop a `.envrc` at a repo root, then `direnv allow` once. After that, `cd`-ing
into the repo auto-loads (and `cd`-ing out auto-unloads) the dev shell:

```sh
echo 'use flake' > .envrc
direnv allow
```
