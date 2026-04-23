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
            echo "  cd             fuzzy-pick a worktree and cd into it (requires fzf)"

        case '*'
            echo "unknown command: $cmd"
            echo "run 'wt' for usage"
            return 1
    end
end
