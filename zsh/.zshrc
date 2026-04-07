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

# Multiple terminal sessions would clobber each other's history without these
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
# SHARE_HISTORY syncs history live across all open terminals
setopt SHARE_HISTORY

# Saves you from retyping when you fat-finger a command name
setopt CORRECT

# Typing a directory name alone will cd into it — less keystrokes
setopt AUTO_CD

# Enables ** recursive glob and qualifiers like *(.) for files only
setopt EXTENDED_GLOB

# Generous history size so you can search back weeks of commands
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
# Avoid polluting history with repeated or secret (space-prefixed) commands
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Homebrew installs completions to its own site-functions dir.
# compinit must run AFTER all FPATH entries and sourced files are loaded,
# which is why this is at the bottom — same pattern Mathias uses in .bash_profile.
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

# zoxide tracks your most-visited directories so `z foo` jumps to ~/projects/foo
eval "$(zoxide init zsh)"

# Starship gives us a consistent prompt across fish and zsh from one config
eval "$(starship init zsh)"
