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
# eza: ls replacement with git status, icons, and sane color defaults
alias ls="eza"
alias l="eza -l"
# -a shows dotfiles, --git adds a git status column per file
alias la="eza -la --git"
# --only-dirs is cleaner than piping through grep
alias lsd="eza -lD"
# tree is built into eza — no need for a separate `tree` install for basic use
alias lt="eza -T --level=2"

# bat: cat with syntax highlighting, line numbers, and git diff markers
alias cat="bat"

# fd: find replacement — `fd pattern` instead of `find . -name '*pattern*'`
alias find="fd"

# ripgrep: grep replacement, respects .gitignore and is 10-100x faster
alias grep="rg"

# tldr: community help pages — `help git commit` instead of `man git-commit`
alias help="tldr"

# === Networking ===
# Quick way to check "what IP does the internet see me as?"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
# Nuclear option when DNS is misbehaving (cached stale records, etc.)
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# === macOS Utilities ===
# .DS_Store files are metadata litter that macOS drops in every directory
# Uses /usr/bin/find explicitly since we alias find→fd (which has different syntax)
alias cleanup="/usr/bin/find . -type f -name '*.DS_Store' -ls -delete"
# Toggle hidden files in Finder — Finder hides them by default which makes
# debugging dotfile issues impossible
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

# === Dev Tools ===
# Update everything in one shot — run this weekly to stay current
alias update="sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup"
# Pipe anything into this to copy it without a trailing newline
alias c="tr -d '\n' | pbcopy"
# Print PATH one entry per line — makes it readable when debugging PATH issues
alias path='echo $PATH | tr ":" "\n"'
# Reload shell config without opening a new terminal
alias reload="exec fish"
# Pipe-friendly map: `find . -name '*.py' | map dirname | sort -u`
alias map="xargs -n1"
