#!/usr/bin/env bash
#
# Provision a remote host end-to-end with a single command:
#   1. SSH in and detect the package manager (apt vs dnf).
#   2. scp the matching install-remote-<pkgmgr>.sh and run it on the remote.
#      (Each installer is arch-aware, handling x86_64 and aarch64 itself.)
#   3. Push the lite dotfiles with dot-push.sh.
#
# Usage:
#   ./provision-remote.sh <host>      # <host> is an ssh-config alias or user@host

set -euo pipefail

if [[ $# -ne 1 || -z "${1:-}" ]]; then
    echo "usage: $(basename "$0") <host>" >&2
    echo "  <host> = an ssh-config Host alias or user@host" >&2
    exit 2
fi

HOST="$1"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Override any RemoteCommand/RequestTTY from the user's ssh config — they break
# running our own command ("Cannot execute command-line and remote command").
# Same workaround dot-push.sh uses.
SSH=(ssh -o RemoteCommand=none -o RequestTTY=no)
SCP=(scp -o RemoteCommand=none -o RequestTTY=no)

echo "==> Detecting package manager on ${HOST}"
# Pick apt or dnf based on what the remote actually has. Each installer is
# arch-aware, so the CPU architecture doesn't affect this choice.
PKGMGR="$("${SSH[@]}" "$HOST" 'command -v apt-get >/dev/null 2>&1 && echo apt || { command -v dnf >/dev/null 2>&1 && echo dnf; }')"
PKGMGR="${PKGMGR//[$'\r\n']/}"   # strip stray CR/LF
echo "    detected: ${PKGMGR:-<none>}"

if [[ -z "$PKGMGR" ]]; then
    echo "error: neither apt-get nor dnf found on ${HOST}" >&2
    exit 1
fi

INSTALLER="${HERE}/install-remote-${PKGMGR}.sh"
if [[ ! -f "$INSTALLER" ]]; then
    echo "error: no installer for package manager '${PKGMGR}' (expected ${INSTALLER})" >&2
    echo "       available installers:" >&2
    ls "${HERE}"/install-remote-*.sh 2>/dev/null | sed 's/^/         /' >&2
    exit 1
fi

REMOTE_NAME="$(basename "$INSTALLER")"
echo "==> Copying ${REMOTE_NAME} to ${HOST}"
"${SCP[@]}" "$INSTALLER" "${HOST}:~/"

echo "==> Running ${REMOTE_NAME} on ${HOST}"
"${SSH[@]}" "$HOST" "bash ~/${REMOTE_NAME}"

echo "==> Pushing dotfiles to ${HOST}"
"${HERE}/dot-push.sh" "$HOST"

echo "==> Done provisioning ${HOST}"
