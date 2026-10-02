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

# Prefer Linux tools from the image over binaries in the shared host home.
export PATH="/usr/local/bin:/usr/local/go/bin:$PATH"

exec "$@"
