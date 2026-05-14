#!/usr/bin/env bash
#
# Push lightweight dotfiles to a remote host.
#
# Usage:
#   ./dot-push.sh user@host                  # explicit user + host
#   ./dot-push.sh whootale                   # any ~/.ssh/config Host alias
#   DRY_RUN=1 ./dot-push.sh user@host        # show what would change
#
# Files pushed:
#   tmux.conf    → $HOME/.tmux.conf
#   zshrc        → $HOME/.zshrc
#   nvim/        → $HOME/.config/nvim/   (directory mirror, --delete)
#
# Remote prerequisites (one-time, e.g. on Amazon Linux 2023):
#   sudo dnf install -y zsh git tmux neovim ripgrep fzf
#   chsh -s "$(which zsh)"     # then re-login

set -euo pipefail

if [[ $# -lt 1 || -z "${1:-}" ]]; then
    echo "usage: $(basename "$0") <user@host | ssh-config-alias>" >&2
    echo "  example: $(basename "$0") ec2-user@ec2-1-2-3-4.compute.amazonaws.com" >&2
    echo "  example: $(basename "$0") whootale" >&2
    exit 2
fi

HOST="$1"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Override any `RemoteCommand`/`RequestTTY` from the user's ssh config —
# they break rsync's "ssh + remote rsync helper" handshake with the error
# "Cannot execute command-line and remote command".
SSH_CMD='ssh -o RemoteCommand=none -o RequestTTY=no'

RSYNC_OPTS=(-av --human-readable -e "$SSH_CMD")
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    RSYNC_OPTS+=(--dry-run)
    echo "==> DRY RUN — no files will be transferred"
fi

echo "==> Pushing to ${HOST}"

# Single files: explicit src/dst pairs are clearer than rsync --include rules.
rsync "${RSYNC_OPTS[@]}" \
    "${HERE}/tmux.conf" "${HOST}:.tmux.conf"

rsync "${RSYNC_OPTS[@]}" \
    "${HERE}/zshrc" "${HOST}:.zshrc"

# Directory mirror with --delete so removed plugin configs don't linger
# on the remote. Trailing slash on the src matters: it copies the *contents*
# of nvim/, not the dir itself, into ~/.config/nvim/.
$SSH_CMD "${HOST}" 'mkdir -p ~/.config/nvim'
rsync "${RSYNC_OPTS[@]}" --delete \
    "${HERE}/nvim/" "${HOST}:.config/nvim/"

echo "==> Done."
echo
echo "Next steps on the remote (only needed once):"
echo "  - Open a new shell so .zshrc is picked up (or 'exec zsh')."
echo "  - Reload tmux config in any running session: prefix + : source-file ~/.tmux.conf"
echo "  - First nvim launch will bootstrap lazy.nvim and clone plugins;"
echo "    run :Lazy sync afterward to verify they all installed cleanly."
