# Completions for the `wt` function (see ../functions/wt.fish).
complete -c wt -f
complete -c wt -n '__fish_use_subcommand' -a 'add'    -d 'Create worktree at <repo>.worktrees/<branch>/ and cd there'
complete -c wt -n '__fish_use_subcommand' -a 'list'   -d 'List all worktrees for the current repo'
complete -c wt -n '__fish_use_subcommand' -a 'remove' -d 'Remove a worktree'
complete -c wt -n '__fish_use_subcommand' -a 'cd'     -d 'Fuzzy-pick a worktree and cd into it'
complete -c wt -n '__fish_use_subcommand' -a 'help'   -d 'Show usage'

# Short aliases — hidden (no description) so they don't clutter tab output.
complete -c wt -n '__fish_use_subcommand' -a 'a'
complete -c wt -n '__fish_use_subcommand' -a 'ls'
complete -c wt -n '__fish_use_subcommand' -a 'rm'
