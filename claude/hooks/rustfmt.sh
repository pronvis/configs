#!/bin/bash
# PostToolUse hook for Claude Code: auto-format .rs files after Edit/Write/MultiEdit.
# Reads the tool-call JSON from stdin, extracts file_path, and runs rustfmt
# on it using the edition declared in the nearest enclosing Cargo.toml
# (falling back to 2021). Silent on success; failures never block the
# parent tool call.

set -u

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[[ -z "$FILE" ]] && exit 0
[[ "$FILE" != *.rs ]] && exit 0
[[ ! -f "$FILE" ]] && exit 0

# Walk up from the file's directory looking for a Cargo.toml so we can
# pick up the right edition for rustfmt.
DIR="$(cd "$(dirname "$FILE")" 2>/dev/null && pwd)" || exit 0
EDITION=""
while [[ "$DIR" != "/" && -n "$DIR" ]]; do
    if [[ -f "$DIR/Cargo.toml" ]]; then
        EDITION=$(grep -E '^edition[[:space:]]*=' "$DIR/Cargo.toml" \
                  | head -1 \
                  | sed -E 's/.*"([0-9]+)".*/\1/')
        [[ -n "$EDITION" ]] && break
    fi
    DIR="$(dirname "$DIR")"
done
EDITION="${EDITION:-2021}"

rustfmt --edition "$EDITION" "$FILE" >/dev/null 2>&1 || true
exit 0
