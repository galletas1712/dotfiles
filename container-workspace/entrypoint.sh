#!/bin/sh
set -eu

if [ "$(id -u)" -eq 0 ]; then
  if ! getent group "$HOST_GID" >/dev/null; then
    groupadd --gid "$HOST_GID" "$HOST_USER"
  fi
  useradd --uid "$HOST_UID" --gid "$HOST_GID" --groups sudo \
    --no-create-home --home-dir "$HOME" --shell /bin/zsh "$HOST_USER"
  printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$HOST_USER" > /etc/sudoers.d/dev-user
  chmod 0440 /etc/sudoers.d/dev-user

  if [ -n "${DOCKER_SOCKET_GID:-}" ]; then
    socket_group=$(getent group "$DOCKER_SOCKET_GID" | cut -d: -f1)
    if [ -z "$socket_group" ]; then
      groupadd --gid "$DOCKER_SOCKET_GID" docker-host
      socket_group=docker-host
    fi
    usermod --append --groups "$socket_group" "$HOST_USER"
  fi

  exec gosu "$HOST_USER" "$0" "$@"
fi

export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

if [ -n "${DEV_GIT_NAME:-}" ] && ! git config --global user.name >/dev/null 2>&1; then
  git config --global user.name "$DEV_GIT_NAME"
fi
if [ -n "${DEV_GIT_EMAIL:-}" ] && ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.email "$DEV_GIT_EMAIL"
fi
if [ -d "$HOME/.config/gh" ]; then
  git config --global credential.https://github.com.helper '!gh auth git-credential'
  git config --global credential.https://gist.github.com.helper '!gh auth git-credential'
fi

exec "$@"
