# Claude Code config

## Files

- `CLAUDE.md` — global instructions, symlinked to `~/.claude/CLAUDE.md`
- `settings.json` — **shared** baseline, committed
- `settings.local.json.example` — template for the machine-specific overlay
- `statusline-command.sh`, `gh-api-readonly-guard.sh` — hook scripts, symlinked

## How settings.json works

Claude Code only reads `~/.claude/settings.json`. There's no native support for a
user-scope `settings.local.json`, so we compile one at install time:

```
dotfiles/claude/settings.json  (shared, committed)
                +
~/.claude/settings.local.json  (machine-specific, NOT in dotfiles repo)
                ↓ jq deep-merge
~/.claude/settings.json        (compiled output — do not edit directly)
```

The local overlay lives at `~/.claude/settings.local.json`, **not** inside the
dotfiles repo — that's the whole point of "local". The dotfiles repo only ships
a `settings.local.json.example` template, which `install.sh` copies into
`~/.claude/` on first run.

## Editing

- **Shared changes** → edit `dotfiles/claude/settings.json`, then `claude-sync`
- **Machine-specific changes** (Bedrock, AWS profile, etc.) → edit `~/.claude/settings.local.json`, then `claude-sync`
- **Never edit `~/.claude/settings.json` directly** — it's overwritten on every sync

The `claude-sync` fish function recompiles in one step. `install.sh` does the
same merge during initial setup.

## If `/config` or another tool writes to `~/.claude/settings.json`

Those edits land in the compiled file and get overwritten on the next
`claude-sync`. Manually port the change into the appropriate source file
(shared or local) before re-syncing.
