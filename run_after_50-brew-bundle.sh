#!/bin/sh
set -eu

if command -v brew >/dev/null 2>&1; then
  brew_cmd=$(command -v brew)
elif [ -x /opt/homebrew/bin/brew ]; then
  brew_cmd=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  brew_cmd=/usr/local/bin/brew
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  brew_cmd=/home/linuxbrew/.linuxbrew/bin/brew
else
  echo 'Install Homebrew before applying this chezmoi configuration.' >&2
  exit 1
fi

eval "$("$brew_cmd" shellenv)"
"$brew_cmd" bundle --upgrade --file="$HOME/.Brewfile"
