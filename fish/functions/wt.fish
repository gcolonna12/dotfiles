# Git worktree helpers: create/list/remove/jump with a flat `<repo>/.worktrees/<slug>/` layout.
function wt --description 'git worktree helpers'
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case add a
            if test (count $argv) -lt 1
                echo "usage: wt add <branch> [extra git worktree add args]"
                return 1
            end
            set -l branch $argv[1]
            set -e argv[1]
            # --git-common-dir always resolves to the MAIN repo's .git from any
            # worktree; its parent is the real project root, so new worktrees
            # anchor there instead of nesting under the current worktree.
            set -l main_root (dirname (git rev-parse --path-format=absolute --git-common-dir))
            or return 1
            # Flatten slashed branch names so feature/foo → one dir, not nested.
            set -l slug (string replace --all / - $branch)
            set -l target "$main_root/.worktrees/$slug"
            git worktree add $target $branch $argv
            or return 1
            # VS Code title vars can't recover the repo name inside a worktree
            # (they read the opened folder), so write the title in per-worktree.
            set -l repo_name (basename $main_root)
            mkdir -p "$target/.vscode"
            printf '{\n    "window.title": "${dirty}%s — %s"\n}\n' $repo_name $branch >"$target/.vscode/settings.json"
            cd $target

        case list ls
            git worktree list

        case remove rm
            if test (count $argv) -lt 1
                echo "usage: wt remove <path>"
                return 1
            end
            git worktree remove $argv

        case clean
            set -l force 0
            if contains -- --force $argv
                set force 1
            end
            set -l main_root (dirname (git rev-parse --path-format=absolute --git-common-dir))
            or return 1
            git -C $main_root fetch --prune 2>/dev/null
            set -l base (git -C $main_root symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | string replace origin/ '')
            test -z "$base"; and set base main
            set -l to_remove
            # Pair each worktree path with its branch using awk (porcelain output has blank-line-separated blocks)
            set -l pairs (git -C $main_root worktree list --porcelain | awk '
                /^worktree / { path = substr($0, 10) }
                /^branch refs\/heads\// { sub(/^branch refs\/heads\//, "", $0); print path "\t" $0 }
            ')
            for pair in $pairs
                set -l parts (string split \t -- $pair)
                set -l path $parts[1]
                set -l branch $parts[2]
                test "$path" = "$main_root"; and continue
                # Skip dirty trees; --ignore-submodules because this repo vendors one.
                set -l dirty (git -C $path status --porcelain --ignore-submodules=all)
                if test -n "$dirty"
                    echo "wt clean: skip (dirty): $path"
                    continue
                end
                if git -C $main_root merge-base --is-ancestor $branch origin/$base 2>/dev/null
                    set to_remove $to_remove "$path"\t"$branch"
                end
            end
            if test (count $to_remove) -eq 0
                echo "wt clean: nothing merged into origin/$base to remove"
                return 0
            end
            if test $force -eq 0
                echo "wt clean: dry run (pass --force to remove)"
                for entry in $to_remove
                    echo "  would remove: "(string split \t -- $entry)[1]" ("(string split \t -- $entry)[2]")"
                end
                return 0
            end
            for entry in $to_remove
                set -l parts (string split \t -- $entry)
                echo "removing: $parts[1] ($parts[2])"
                git -C $main_root worktree remove --force $parts[1]
                and git -C $main_root branch -d $parts[2] 2>/dev/null
            end

        case cd
            set -l target (git worktree list --porcelain | grep '^worktree ' | awk '{print $2}' | fzf)
            test -n "$target"
            and cd $target

        case '' -h --help help
            echo "usage: wt <command>"
            echo ""
            echo "commands:"
            echo "  add <branch>   create worktree at <main-repo>/.worktrees/<slug>/ (flat) and cd into it"
            echo "  list           list all worktrees for the current repo"
            echo "  remove <path>  remove a worktree"
            echo "  clean [--force]  remove worktrees merged into origin/HEAD, skipping dirty ones (dry-run by default)"
            echo "  cd             fuzzy-pick a worktree and cd into it (requires fzf)"

        case '*'
            echo "unknown command: $cmd"
            echo "run 'wt' for usage"
            return 1
    end
end
