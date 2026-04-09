#!/usr/bin/env bash
# Claude Code status line

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context window
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Cost + duration
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

PAD="  "

# ── LINE 1: [Model] 📁 dir | 🌿 branch ───────────────────────────────────────
dirname=$(basename "$cwd")
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
remote_url=$(git -C "$cwd" --no-optional-locks remote get-url origin 2>/dev/null || true)

# Convert remote to HTTPS GitHub URL, resolving SSH config aliases
github_url=""
if [ -n "$remote_url" ]; then
    if echo "$remote_url" | grep -q "https://github.com"; then
        github_url=$(echo "$remote_url" | sed 's|\.git$||')
    elif echo "$remote_url" | grep -qE "^git@[^:]+:"; then
        ssh_host=$(echo "$remote_url" | sed 's/git@\([^:]*\):.*/\1/')
        resolved=$(ssh -G "$ssh_host" 2>/dev/null | awk '/^hostname / {print $2}')
        if [ "$resolved" = "github.com" ]; then
            repo_path=$(echo "$remote_url" | sed 's|git@[^:]*:||; s|\.git$||')
            github_url="https://github.com/${repo_path}"
        fi
    fi
fi

# Extract short model name
model_short=""
if [ -n "$model" ]; then
    model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
    if   echo "$model_lower" | grep -q "opus";   then model_short="Opus"
    elif echo "$model_lower" | grep -q "sonnet"; then model_short="Sonnet"
    elif echo "$model_lower" | grep -q "haiku";  then model_short="Haiku"
    else model_short="$model"
    fi
fi

printf "%s" "$PAD"
[ -n "$model_short" ] && printf "${CYAN}[%s]${RESET}  " "$model_short"
printf "📁 ${BOLD}%s${RESET}" "$dirname"
[ -n "$branch" ] && printf "  ${DIM}|${RESET}  🌿 ${MAGENTA}${BOLD}%s${RESET}" "$branch"
echo ""

# ── LINE 2: context bar | % | $cost | ⏱ elapsed ─────────────────────────────
if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")

    if   [ "$used_int" -ge 80 ]; then bar_color="$RED"
    elif [ "$used_int" -ge 50 ]; then bar_color="$YELLOW"
    else                               bar_color="$GREEN"
    fi

    bar_width=15
    filled=$(( used_int * bar_width / 100 ))
    empty=$(( bar_width - filled ))

    filled_bar=""
    empty_bar=""
    i=0; while [ $i -lt $filled ]; do filled_bar="${filled_bar}█"; i=$(( i + 1 )); done
    i=0; while [ $i -lt $empty  ]; do empty_bar="${empty_bar}░";   i=$(( i + 1 )); done

    printf "%s${bar_color}%s${RESET}${DIM}%s${RESET}  ${BOLD}%s%%${RESET}" \
        "$PAD" "$filled_bar" "$empty_bar" "$used_int"
fi

if [ -n "$cost" ]; then
    cost_fmt=$(printf '%.2f' "$cost")
    printf "  ${DIM}|${RESET}  ${YELLOW}💰 \$%s${RESET}" "$cost_fmt"
fi

if [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ]; then
    secs=$(( duration_ms / 1000 ))
    hrs=$(( secs / 3600 ))
    mins=$(( (secs % 3600) / 60 ))
    secs=$(( secs % 60 ))
    if [ "$hrs" -gt 0 ]; then
        printf "  ${DIM}|${RESET}  ⏱ ${DIM}%dh %dm${RESET}" "$hrs" "$mins"
    elif [ "$mins" -gt 0 ]; then
        printf "  ${DIM}|${RESET}  ⏱ ${DIM}%dm %ds${RESET}" "$mins" "$secs"
    else
        printf "  ${DIM}|${RESET}  ⏱ ${DIM}%ds${RESET}" "$secs"
    fi
fi

echo ""

# ── LINE 3: GitHub repo link ──────────────────────────────────────────────────
if [ -n "$github_url" ]; then
    printf "%s🔗 ${BLUE}%s${RESET}\n" "$PAD" "$github_url"
fi
