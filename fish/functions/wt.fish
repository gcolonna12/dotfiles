# Git worktree helpers: create/list/remove/jump with `<repo>.worktrees/<branch>/` layout.
# Matches the default layout of the VS Code extension `jackiotyu.git-worktree-manager`.
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
            set -l repo_root (git rev-parse --show-toplevel)
            or return 1
            set -l repo_name (basename $repo_root)
            set -l parent (dirname $repo_root)
            set -l target "$parent/$repo_name.worktrees/$branch"
            git worktree add $target $branch $argv
            and cd $target

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
            if not command -q gh
                echo "wt clean: requires 'gh' (GitHub CLI)"
                return 1
            end
            set -l repo_root (git rev-parse --show-toplevel)
            or return 1
            set -l to_remove
            # Pair each worktree path with its branch using awk (porcelain output has blank-line-separated blocks)
            set -l pairs (git worktree list --porcelain | awk '
                /^worktree / { path = substr($0, 10) }
                /^branch refs\/heads\// { sub(/^branch refs\/heads\//, "", $0); print path "\t" $0 }
            ')
            for pair in $pairs
                set -l parts (string split \t -- $pair)
                set -l path $parts[1]
                set -l branch $parts[2]
                test "$path" = "$repo_root"; and continue
                set -l state (gh pr list --head $branch --state all --json state --jq '.[0].state' 2>/dev/null)
                if test "$state" = MERGED -o "$state" = CLOSED
                    set to_remove $to_remove "$path"\t"$branch"\t"$state"
                end
            end
            if test (count $to_remove) -eq 0
                echo "wt clean: no merged or closed worktrees found"
                return 0
            end
            if test $force -eq 0
                echo "wt clean: dry run (pass --force to remove)"
                for entry in $to_remove
                    echo "  would remove: "(string split \t -- $entry)[1]" ("(string split \t -- $entry)[2]", "(string split \t -- $entry)[3]")"
                end
                return 0
            end
            for entry in $to_remove
                set -l parts (string split \t -- $entry)
                echo "removing: $parts[1] ($parts[2], $parts[3])"
                git worktree remove $parts[1]
                and git branch -D $parts[2] 2>/dev/null
            end

        case cd
            set -l target (git worktree list --porcelain | grep '^worktree ' | awk '{print $2}' | fzf)
            test -n "$target"
            and cd $target

        case '' -h --help help
            echo "usage: wt <command>"
            echo ""
            echo "commands:"
            echo "  add <branch>   create worktree at <repo>.worktrees/<branch>/ and cd into it"
            echo "  list           list all worktrees for the current repo"
            echo "  remove <path>  remove a worktree"
            echo "  clean [--force]  remove worktrees whose PR is merged or closed (dry-run by default)"
            echo "  cd             fuzzy-pick a worktree and cd into it (requires fzf)"

        case '*'
            echo "unknown command: $cmd"
            echo "run 'wt' for usage"
            return 1
    end
end
