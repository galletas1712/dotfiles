# Dotfiles and host tools

This chezmoi source manages the shared shell, Git, tmux, Starship, Yazi, and
macOS desktop configuration. `~/.Brewfile` lists host tools for macOS and
Linux. Each `chezmoi apply` runs Homebrew Bundle, including available updates.

Machine-specific shell settings belong in `~/.zshrc.local`, which is not
managed here. Teleport login state and agent history stay in the host home.

On Ubuntu, install Homebrew at its supported Linux prefix before the first
apply. Chezmoi installs the apt prerequisites when its Ubuntu bootstrap script
changes. Keep the container engine installed through the host system package
manager. The [development container](container-workspace/README.md) uses
host `~/workspace` as its home and shares selected login and history folders.

The existing Home Manager target files are intentionally left on each host
during the transition. Their source templates are no longer managed by this
repository, so future applies do not rewrite the running Nix configuration.
