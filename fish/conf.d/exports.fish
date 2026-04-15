# Default editor for git commits, crontab, etc.
set -gx EDITOR vim

# Push VS Code IPC into tmux so `code` CLI and Claude Code autoConnectIde work from tmux panes
if set -q TMUX; and set -q VSCODE_IPC_HOOK_CLI
    tmux setenv VSCODE_IPC_HOOK_CLI "$VSCODE_IPC_HOOK_CLI"
    tmux setenv VSCODE_GIT_IPC_HANDLE "$VSCODE_GIT_IPC_HANDLE"
end

# Prevents Python from choking on non-ASCII characters in pipes and redirects
set -gx PYTHONIOENCODING UTF-8

# Consistent encoding across all tools — prevents locale-dependent bugs in scripts
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Makes man page section headers yellow instead of bold-only — easier to scan
set -gx LESS_TERMCAP_md (set_color -o yellow)

# By default, quitting less clears the screen — this keeps the content visible
# so you can refer back to it without re-opening the man page
set -gx MANPAGER "less -X"
