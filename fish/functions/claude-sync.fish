# Recompile ~/.claude/settings.json from dotfiles base + local overlay.
# Run after editing claude/settings.json or ~/.claude/settings.local.json.
function claude-sync --description 'recompile ~/.claude/settings.json from base + local overlay'
    # Resolve dotfiles path via this symlinked function file — adapts if repo moves.
    set -l fn_path (realpath (status -f))
    set -l dotfiles (dirname (dirname (dirname $fn_path)))
    set -l base "$dotfiles/claude/settings.json"
    set -l overlay "$HOME/.claude/settings.local.json"
    set -l target "$HOME/.claude/settings.json"

    if not command -q jq
        echo "claude-sync: jq not installed" >&2
        return 1
    end
    if not test -f $base
        echo "claude-sync: missing $base" >&2
        return 1
    end

    if test -f $overlay
        jq -s '.[0] * .[1]' $base $overlay > $target.tmp
        and mv $target.tmp $target
        and echo "Compiled $target (base + local overlay)"
    else
        cp $base $target
        and echo "Compiled $target (base only — no local overlay found)"
    end
end
