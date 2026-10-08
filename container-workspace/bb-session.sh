#!/usr/bin/env bash
set -euo pipefail

export BB_DATA_DIR=${BB_DATA_DIR:-$HOME/.bb}
zmx run bb -d npx --yes bb-app@latest
exec zmx wait bb
