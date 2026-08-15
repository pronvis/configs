#!/usr/bin/env bash
#
# Record this Claude Code session's status, keyed by the tmux pane it runs in,
# so `claude-sessions` can list every live session and jump to it.
#
# Registered in claude/settings.json against several hook events, each passing
# the status it represents as $1:
#
#   SessionStart      idle      a session appeared, not doing anything yet
#   UserPromptSubmit  working   the user just asked for something
#   PostToolUse       working   a tool finished, so we are past any permission
#                               prompt and back to work
#   Notification      waiting   Claude needs the user (a permission prompt)
#   Stop              idle      the turn ended
#   SessionEnd        gone      deregister
#
# Deliberately dependency-free and does no real JSON parsing: it runs on every
# tool call, so it stays a couple of syscalls. The pane id is enough to identify
# the session, because `claude-sessions` resolves names from the live tmux pane
# list.

set -uo pipefail

status="${1:-idle}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-tmux"

# Read the hook payload off stdin so Claude Code never writes into a closed
# pipe. Only the Notification event looks at it; everywhere else this is just
# the drain.
payload=''
[ -t 0 ] || payload=$(cat)

# Claude Code fires Notification for two unrelated things: it needs the user
# (a permission prompt), and the input prompt merely sitting untouched for a
# minute. The second is an idle session, not one waiting on anything, so leave
# whatever status is already recorded alone — in particular do not clobber a
# real permission prompt that this idle notice happens to follow.
if [ "$status" = "waiting" ]; then
    case "$payload" in
        *'waiting for your input'* | *idle_prompt*) exit 0 ;;
    esac
fi

# Claude is not running under tmux (plain terminal, cloud, CI) — there is no
# pane to attribute this session to, so there is nothing to display.
[ -n "${TMUX_PANE:-}" ] || exit 0

# Pane ids look like "%531"; drop the sigil so the state file name is plain.
state_file="$state_dir/${TMUX_PANE#%}"

if [ "$status" = "gone" ]; then
    rm -f "$state_file"
    exit 0
fi

mkdir -p "$state_dir" || exit 0

# status <TAB> last-updated-epoch. The timestamp lets the picker flag sessions
# that stopped reporting, which is how a session killed without SessionEnd
# (kill -9, closed pane, crashed host) shows up as stale rather than "working".
printf '%s\t%s\n' "$status" "$(date +%s)" >"$state_file"
