#!/usr/bin/env bash
# Stop hook: a gentle, non-blocking reminder to run the rust-reviewer agent
# (/rust-review) when this session left uncommitted changes to *.rs files.
#
# It never blocks (always exits 0); it only emits a systemMessage so the
# reminder shows up in the transcript. Disable by setting RUST_REVIEW_REMINDER=0
# or by removing the Stop hook from .claude/settings.json.

set -uo pipefail

# Consume the hook's JSON stdin (we don't need it).
cat >/dev/null 2>&1 || true

[ "${RUST_REVIEW_REMINDER:-1}" = "0" ] && exit 0

dir="${CLAUDE_PROJECT_DIR:-$PWD}"

if git -C "$dir" status --porcelain 2>/dev/null | grep -q '\.rs$'; then
  printf '%s\n' '{"systemMessage": "⚠️ Rust files changed this session — run the rust-reviewer agent (/rust-review) before considering the work done."}'
fi

exit 0
