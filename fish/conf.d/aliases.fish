# === Navigation ===
# Fish supports .. natively, but these save keystrokes for deeper traversal
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a ..... 'cd ../../../..'
abbr -a dl 'cd ~/Downloads'
abbr -a dt 'cd ~/Desktop'
# Single-letter git saves hundreds of keystrokes per day
abbr -a g git

# === Modern CLI replacements ===
# Only aliased when the tool is installed — falls back to the system default otherwise.

# eza: ls replacement with git status, icons, and sane color defaults
if command -q eza
    alias ls="eza"
    alias l="eza -l"
    # -a shows dotfiles, --git adds a git status column per file
    alias la="eza -la --git"
    # --only-dirs is cleaner than piping through grep
    alias lsd="eza -lD"
    # tree is built into eza — no need for a separate `tree` install for basic use
    alias lt="eza -T --level=2"
end

# bat: cat with syntax highlighting, line numbers, and git diff markers
if command -q bat;  alias cat="bat";  end

# fd: find replacement — `fd pattern` instead of `find . -name '*pattern*'`
if command -q fd;   alias find="fd";  end

# ripgrep: grep replacement, respects .gitignore and is 10-100x faster
if command -q rg;   alias grep="rg";  end

# tldr: community help pages — `help git commit` instead of `man git-commit`
if command -q tldr; alias help="tldr"; end

# === Networking ===
# Quick way to check "what IP does the internet see me as?"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# === Dev Tools ===
# Print PATH one entry per line — makes it readable when debugging PATH issues
alias showpath='string join \n $PATH'
# Reload shell config without opening a new terminal
alias reload="exec fish"
# Pipe-friendly map: `find . -name '*.py' | map dirname | sort -u`
alias map="xargs -n1"

# === macOS only ===
if test (uname) = "Darwin"
    alias localip="ipconfig getifaddr en0"
    # Nuclear option when DNS is misbehaving (cached stale records, etc.)
    alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"
    # .DS_Store files are metadata litter that macOS drops in every directory.
    # Use /usr/bin/find explicitly — `find` may be aliased to fd (different syntax).
    alias cleanup="/usr/bin/find . -type f -name '*.DS_Store' -ls -delete"
    # Toggle hidden files in Finder
    alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
    alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
    # Clean desktop before screen sharing or presentations
    alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
    alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
    # Lock screen when stepping away — muscle memory beats Ctrl+Cmd+Q
    abbr -a afk "pmset displaysleepnow"
    # Instant mute/unmute without touching the menu bar
    alias stfu="osascript -e 'set volume output muted true'"
    alias pumpitup="osascript -e 'set volume output volume 100'"
    # Fix "Open With" menu showing duplicate entries after app updates
    alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
    # Update everything in one shot — run this weekly to stay current
    alias update="sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup"
    # Clear macOS quarantine flag on claude after brew install/upgrade
    alias unquarantine-claude="xattr -dr com.apple.quarantine (brew --prefix)/bin/claude"
    # Pipe anything into this to copy it without a trailing newline
    alias c="tr -d '\n' | pbcopy"
end
