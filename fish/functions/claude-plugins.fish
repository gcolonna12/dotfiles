# Launch Claude Code with a curated set of plugins force-loaded via --plugin-dir.
#
# Why --plugin-dir and not the normal marketplace install: the org enforces an
# enterprise marketplace allowlist that permits only the internal GitLab source,
# so `claude` (and `plugin marketplace add`) won't load the official marketplace.
#
# Why individual plugin dirs and not the marketplace root: --plugin-dir loads a
# dir as a *plugin* only if it contains .claude-plugin/plugin.json -- a code path
# the allowlist does not gate. The official marketplace root has only
# marketplace.json, so --plugin-dir treats it as a *marketplace* and it is
# rejected. Individual plugin dirs each have their own plugin.json, so they load
# directly from local files. (llm-wiki root works because it IS a plugin.)
#
# Only plugins with local content can be loaded this way. A marketplace entry
# whose source is a remote repo (superpowers, understand-anything) is fetched
# into cache/<marketplace>/<plugin>/<version>/ instead of the marketplace tree,
# so it does have local content once installed -- those paths are resolved by
# version below. The *-lsp plugins are the genuine exception: their upstream
# entries are content-less stubs, so pyright-lsp is provided from local-plugins/
# instead (dotfiles-managed, symlinked by install.sh) with its lspServers block.
#
# `claude-plugins --update` git-pulls the llm-wiki checkout (the only source
# that is a real clone). The official plugins are synced by Claude Code and
# cannot be pulled independently, so they stay pinned to what is on disk.
function claude-plugins --description 'run claude with curated local plugins force-loaded'
    set -l official "$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins"
    set -l llm_wiki "$HOME/.claude/plugins/marketplaces/llm-wiki"
    set -l cache "$HOME/.claude/plugins/cache"

    if test "$argv[1]" = --update
        if test -d "$llm_wiki/.git"
            git -C "$llm_wiki" pull --ff-only
        else
            echo "claude-plugins: $llm_wiki is not a git clone; nothing to update" >&2
            return 1
        end
        return
    end

    # Curated selection -- the plugins I actually want, not the whole marketplace.
    set -l dirs \
        "$llm_wiki" \
        "$official/code-simplifier" \
        "$official/claude-md-management" \
        "$official/claude-code-setup" \
        "$HOME/.claude/local-plugins/pyright-lsp" \
        "$HOME/.claude/local-plugins/codegraph"

    # Cached remote-source plugins: take the highest version installed (fish sorts
    # glob results numerically). Falling back to the bare path when nothing is
    # installed lets the check below report it as a normal skip.
    for cached in "$cache/claude-plugins-official/superpowers" \
        "$cache/understand-anything/understand-anything"
        set -l versions $cached/*/
        if set -q versions[1]
            set -a dirs $versions[-1]
        else
            set -a dirs $cached
        end
    end

    set -l flags
    for d in $dirs
        if test -f "$d/.claude-plugin/plugin.json"
            set -a flags --plugin-dir "$d"
        else
            echo "claude-plugins: skipping $d (no local plugin.json)" >&2
        end
    end

    claude $flags $argv
end
