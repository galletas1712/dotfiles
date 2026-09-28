#!/bin/sh
set -eu
export PATH="$HOME/.local/bin:$PATH"

installer=$(mktemp)
trap 'rm -f "$installer"' EXIT
curl -fsSL https://chatgpt.com/codex/install.sh -o "$installer"
CODEX_NON_INTERACTIVE=1 sh "$installer"
