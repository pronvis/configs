#!/usr/bin/env bash
# Watch every `nvim --embed` core; when one's RSS crosses THRESHOLD_MB, snapshot
# its internals (lua mem, buffers, extmarks-by-namespace, LSP clients) through
# its RPC socket into the report log — so a runaway nvim names its own cause.
#
# Why this exists: a single nvim core can balloon to many GB over a long
# session; with ~25 nvims open at once (tmux-resurrect restores every pane) that
# sums past physical RAM and the machine OOM-kills. The report tells us which
# category grows (Lua heap / leaked extmarks / a huge buffer / an LSP client).
#
# Kept alive by launchd (launchd/com.pronvis.nvim-mem-watch.plist). Run by hand:
#   ./nvim-mem-watch.sh 1500      # threshold in MB (default 1500)
#   POLL=15 ./nvim-mem-watch.sh   # scan every 15s (default 30)
set -u

THRESHOLD_MB="${1:-1500}"
POLL="${POLL:-30}"                       # seconds between scans
ROTATE_BYTES=$((5 * 1024 * 1024))        # rotate the report once it passes 5MB

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DUMP="$SCRIPT_DIR/nvim-leak-dump.lua"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim-leak"
REPORT="$STATE_DIR/report.log"

mkdir -p "$STATE_DIR"
echo "[$(date '+%F %T')] watcher up: snapshot nvim cores >= ${THRESHOLD_MB}MB (poll ${POLL}s) -> $REPORT" >>"$REPORT"

# snapped[pid]=growth-bucket, so each core is dumped once per ~512MB it gains.
# Plain indexed array (PIDs are numeric) — works under macOS's stock bash 3.2,
# which launchd uses and which lacks `declare -A`.
snapped=()
while true; do
    # keep the report bounded — launchd runs this forever
    if [ -f "$REPORT" ]; then
        sz=$(stat -f%z "$REPORT" 2>/dev/null || stat -c%s "$REPORT" 2>/dev/null || echo 0)
        [ "${sz:-0}" -gt "$ROTATE_BYTES" ] && mv -f "$REPORT" "$REPORT.1"
    fi
    while read -r pid rss; do
        [ -z "${pid:-}" ] && continue
        mb=$((rss / 1024))
        [ "$mb" -ge "$THRESHOLD_MB" ] || continue
        # snapshot each pid once per ~512MB of growth (not every poll)
        bucket=$((mb / 512))
        [ "${snapped[$pid]:-}" = "$bucket" ] && continue
        snapped[$pid]=$bucket
        # nvim's RPC socket: .../nvim.<pid>.<n>. lsof reports it under /var/folders
        # (a symlink to /private/var), so don't anchor on the /private prefix.
        sock=$(lsof -p "$pid" 2>/dev/null | grep -oE '/[^[:space:]]*/nvim\.[0-9]+\.[0-9]+' | head -1)
        echo "[$(date '+%F %T')] pid=$pid rss=${mb}MB sock=${sock:-none}" >>"$REPORT"
        if [ -n "$sock" ]; then
            nvim --server "$sock" --remote-send "<C-\\><C-N>:luafile $DUMP<CR>" 2>>"$REPORT" \
                || echo "  (core unresponsive — likely blocked allocating)" >>"$REPORT"
        fi
    done < <(ps -axo pid,rss,command | awk '/nvim --embed/ && !/awk/ {print $1, $2}')
    sleep "$POLL"
done
