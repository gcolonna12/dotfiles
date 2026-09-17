# Prezto manages zsh: it owns history, completion, editor keybindings, and
# the interactive niceties (syntax-highlighting, autosuggestions,
# history-substring-search). The module list lives in ~/.zpreztorc.
# We keep only the bits that are genuinely ours below: PATH, SDKMAN,
# starship, zoxide, and the modular exports/aliases/functions.
if [[ -s "$HOME/.zprezto/init.zsh" ]]; then
    source "$HOME/.zprezto/init.zsh"
fi

# ~/bin is where we keep personal scripts that should be runnable from anywhere
export PATH="$HOME/bin:$PATH"

# SDKMAN manages JDK versions, Gradle, Maven, etc.
# Must init BEFORE aliases are loaded — SDKMAN's init script uses `find`,
# and our aliases remap find→fd which breaks SDKMAN's internal sourcing.
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Modular config: keeps this file small and lets us organize by concern.
# ~/.extra is git-ignored so you can put machine-specific or secret stuff there.
for file in ~/.zsh/{exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Without this, *.txt won't match README.TXT — annoying on case-insensitive macOS filesystems
setopt NO_CASE_GLOB

# Typing a directory name alone will cd into it — less keystrokes
setopt AUTO_CD

# Enables ** recursive glob and qualifiers like *(.) for files only
setopt EXTENDED_GLOB

# zoxide tracks your most-visited directories so `z foo` jumps to ~/projects/foo
if command -v zoxide &>/dev/null; then eval "$(zoxide init zsh)"; fi

# Starship gives us a consistent prompt across fish and zsh from one config
if command -v starship &>/dev/null; then eval "$(starship init zsh)"; fi


# Added by Antigravity CLI installer
export PATH="/Users/gianpi/.local/bin:$PATH"
