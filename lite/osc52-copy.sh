#!/usr/bin/env bash
#
# Send the text on stdin to the system clipboard via OSC 52, double-wrapped in
# tmux DCS passthrough so it survives nested tmux (remote tmux + local mac tmux).
# This mirrors the working nvim path in lite/nvim/init.lua and deliberately does
# NOT rely on tmux's `set-clipboard`, which doesn't work on this setup.
#
# Called from tmux copy-mode:  copy-pipe-and-cancel "bash ~/.tmux-osc52.sh #{pane_tty}"
#   - stdin : the copied selection
#   - $1    : the pane's tty to write the escape sequence to
#
# Each tmux layer strips exactly one DCS wrapper; alacritty receives clean OSC 52.

set -euo pipefail

target="${1:-/dev/tty}"
esc=$'\033'
st="${esc}\\" # ESC \  (String Terminator)

# base64 the selection; strip the line wrapping coreutils adds at 76 cols.
b64=$(base64 | tr -d '\r\n')
osc="${esc}]52;c;${b64}${st}"

# Wrap a sequence in tmux passthrough: ESC Ptmux; <ESC doubled> ESC \
dcs_wrap() {
    local inner=${1//${esc}/${esc}${esc}}
    printf '%sPtmux;%s%s' "$esc" "$inner" "$st"
}

# One wrap per tmux layer (remote, then local mac).
printf '%s' "$(dcs_wrap "$(dcs_wrap "$osc")")" >"$target"
