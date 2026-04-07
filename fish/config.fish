# ~/bin is where we keep personal scripts that should be runnable from anywhere
fish_add_path ~/bin

# Fish auto-sources everything in conf.d/, so exports.fish and aliases.fish
# placed there will load automatically — no explicit sourcing needed.
# Fish also handles history, case-insensitive matching, autocd, and typo
# correction natively or via built-in features, unlike bash/zsh which need
# explicit opt-in for each.

# zoxide tracks your most-visited directories so `z foo` jumps to ~/projects/foo
zoxide init fish | source

# Starship gives us a consistent prompt across fish and zsh from one config
starship init fish | source
