# ~/bin is where we keep personal scripts that should be runnable from anywhere
fish_add_path ~/bin

# Fish auto-sources everything in conf.d/, so exports.fish and aliases.fish
# placed there will load automatically — no explicit sourcing needed.
# Fish also handles history, case-insensitive matching, autocd, and typo
# correction natively or via built-in features, unlike bash/zsh which need
# explicit opt-in for each.

# fzf provides fuzzy finding for files, directories, and history
# Ctrl+R = history search, Ctrl+T = file search, Alt+C = cd into directory
if command -q fzf
    fzf --fish | source
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --info=inline"
    # Use fd for faster traversal if available
    if command -q fd
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
    end
end

# zoxide tracks your most-visited directories so `z foo` jumps to ~/projects/foo
if command -q zoxide
    zoxide init fish | source
end

# Starship gives us a consistent prompt across fish and zsh from one config
if command -q starship
    starship init fish | source
end
