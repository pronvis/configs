#!/bin/bash
set -f

# A compact, JSON-in/ANSI-out renderer for Codex-compatible wrappers.
#
# Codex 0.149.x currently renders its TUI status line from [tui].status_line
# directly, rather than invoking an external command. This renderer is kept
# as the reusable command counterpart for integrations that provide JSON on
# stdin (and mirrors the useful parts of the Claude status line).

input=$(cat)

if [ -z "$input" ]; then
    printf "Codex"
    exit 0
fi

blue='\033[38;2;0;153;255m'
green='\033[38;2;0;175;80m'
cyan='\033[38;2;86;182;194m'
red='\033[38;2;255;85;85m'
yellow='\033[38;2;230;200;0m'
white='\033[38;2;220;220;220m'
magenta='\033[38;2;180;140;255m'
dim='\033[2m'
reset='\033[0m'
sep=" ${dim}│${reset} "

json_value() {
    jq -r "$1 // empty" <<<"$input" 2>/dev/null
}

color_for_pct() {
    local pct=$1
    if [ "$pct" -ge 90 ] 2>/dev/null; then printf "$red"
    elif [ "$pct" -ge 70 ] 2>/dev/null; then printf "$yellow"
    elif [ "$pct" -ge 50 ] 2>/dev/null; then printf "\033[38;2;255;176;85m"
    else printf "$green"
    fi
}

build_bar() {
    local pct=${1:-0}
    local width=${2:-8}
    [ "$pct" -lt 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100

    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar_color
    bar_color=$(color_for_pct "$pct")

    local bar=""
    local i
    for ((i=0; i<filled; i++)); do bar+="●"; done
    for ((i=0; i<empty; i++)); do bar+="○"; done
    printf "%b%s%b" "$bar_color" "$bar" "$reset"
}

model=$(json_value '.model.display_name // .model_name // .model // "Codex"')
[ -z "$model" ] && model=Codex

effort=$(json_value '.reasoning_effort // .model.reasoning_effort // .effort // empty')

cwd=$(json_value '.cwd // .working_directory // empty')
[ -z "$cwd" ] && cwd=$(pwd)
directory=$(basename "$cwd")

git_branch=""
git_dirty=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    [ -z "$git_branch" ] && git_branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
        git_dirty="*"
    fi
fi

context_pct=$(json_value '.context_used_percent // .context_usage.used_percent // .context_window.used_percentage // empty')
if [ -z "$context_pct" ]; then
    context_size=$(json_value '.context_window_size // .context_window.context_window_size // empty')
    context_used=$(json_value '.context_usage.tokens_used // .context_window.current_usage.total_tokens // empty')
    if [ -n "$context_size" ] && [ -n "$context_used" ] && [ "$context_size" -gt 0 ] 2>/dev/null; then
        context_pct=$(( context_used * 100 / context_size ))
    fi
fi
[ -n "$context_pct" ] && context_pct=$(printf "%.0f" "$context_pct" 2>/dev/null)

tokens=$(json_value '.tokens_used // .usage.total_tokens // .context_usage.tokens_used // empty')
token_text=""
if [ -n "$tokens" ] && [ "$tokens" -gt 0 ] 2>/dev/null; then
    token_text="$((tokens / 1000))k"
fi

primary_pct=$(json_value '.rate_limits.primary.used_percentage // .rate_limits.five_hour.used_percentage // empty')
weekly_pct=$(json_value '.rate_limits.secondary.used_percentage // .rate_limits.seven_day.used_percentage // empty')

line="${blue}${model}${reset}"
[ -n "$effort" ] && line+="${sep}${magenta}◑ ${effort}${reset}"
if [ -n "$context_pct" ]; then
    context_color=$(color_for_pct "$context_pct")
    line+="${sep}${context_color}${context_pct}%${reset} $(build_bar "$context_pct" 8)"
fi
line+="${sep}${cyan}${directory}${reset}"
if [ -n "$git_branch" ]; then
    line+=" ${green}(${git_branch}${red}${git_dirty}${green})${reset}"
fi
[ -n "$token_text" ] && line+="${sep}${white}${token_text}${reset}"

if [ -n "$primary_pct" ]; then
    primary_pct=$(printf "%.0f" "$primary_pct" 2>/dev/null)
    line+="${sep}${dim}5h${reset} $(build_bar "$primary_pct" 8) ${white}${primary_pct}%${reset}"
fi
if [ -n "$weekly_pct" ]; then
    weekly_pct=$(printf "%.0f" "$weekly_pct" 2>/dev/null)
    line+=" ${dim}7d${reset} $(build_bar "$weekly_pct" 8) ${white}${weekly_pct}%${reset}"
fi

printf "%b" "$line"
