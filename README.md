# Dotfiles and host tools

This chezmoi source manages the shared shell, Git, tmux, Starship, Yazi, and
macOS desktop configuration. `~/.Brewfile` lists host tools for macOS and
Linux. Each `chezmoi apply` runs Homebrew Bundle, including available updates.
Claude Code uses Anthropic's latest release channel on both hosts. Codex CLI
uses OpenAI's standalone installer, which checks for the latest stable release
on every `chezmoi apply`.

Machine-specific shell settings belong in `~/.zshrc.local`, which is not
managed here. Teleport login state and agent history stay in the host home.

On Ubuntu, install Homebrew at its supported Linux prefix before the first
apply. Chezmoi installs the apt prerequisites when its Ubuntu bootstrap script
changes. Keep the container engine installed through the host system package
manager. The [development container](container-workspace/README.md) uses
host `~/workspace` as its home and shares selected login and history folders.

Chezmoi does not manage the former Home Manager configuration or any Nix
installation files.
