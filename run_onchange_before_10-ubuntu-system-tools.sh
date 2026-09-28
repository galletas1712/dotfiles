#!/bin/sh
set -eu

if [ "$(uname -s)" != Linux ] || [ ! -r /etc/os-release ]; then
  exit 0
fi
. /etc/os-release
if [ "$ID" != ubuntu ]; then
  exit 0
fi

# Homebrew and container-engine bootstrap prerequisites.
sudo apt-get update
sudo apt-get install -y \
  build-essential git curl file procps
