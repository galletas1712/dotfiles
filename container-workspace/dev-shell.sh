#!/usr/bin/env bash
set -euo pipefail

enable_docker=false
host_mounts=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --docker)
      enable_docker=true
      shift
      ;;
    --mount-host)
      if [[ $# -lt 2 || $2 != /* || ! -e $2 ]]; then
        echo '--mount-host needs an existing absolute path.' >&2
        exit 2
      fi
      host_mounts+=("$2")
      shift 2
      ;;
    *) break ;;
  esac
done

host_home=$HOME
host_workspace="$host_home/workspace"
mkdir -p "$host_workspace"
workspace_arg=${1:-$host_workspace}
if [[ $workspace_arg == -- ]]; then
  workspace_arg=$host_workspace
elif [[ $# -gt 0 ]]; then
  shift
fi
workspace=$(cd "$workspace_arg" && pwd -P)
if [[ ${1:-} == -- ]]; then
  shift
fi
if [[ $# -eq 0 ]]; then set -- zsh; fi
image=schwinns-dev
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
host_user=$(id -un)
container_home=$host_workspace

docker info >/dev/null
if [[ $(uname -s) == Linux ]]; then
  # Leave room for project files and temporary Docker build layers on Odin.
  min_free_gib=20
  docker_root=$(docker info --format '{{.DockerRootDir}}')
  for storage_path in "$host_workspace" "$docker_root"; do
    available_kb=$(df -Pk "$storage_path" | awk 'NR == 2 { print $4 }')
    if (( available_kb < min_free_gib * 1024 * 1024 )); then
      echo "Less than $min_free_gib GiB free at $storage_path; skipping image build." >&2
      exit 1
    fi
  done
fi
docker build --pull --quiet \
  --build-arg "REFRESH=$(date +%F)" \
  --tag "$image" "$script_dir"

run_args=(
  run --rm --init
  --network host
  --env "HOME=$container_home"
  --env "USER=$host_user"
  --env "LOGNAME=$host_user"
  --env "HOST_USER=$host_user"
  --env "HOST_UID=$(id -u)"
  --env "HOST_GID=$(id -g)"
  --env "DEV_GIT_NAME=$(git config --global user.name 2>/dev/null || true)"
  --env "DEV_GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)"
  --mount "type=bind,source=$host_workspace,target=$container_home"
  --workdir "$workspace"
)
for host_mount in "${host_mounts[@]}"; do
  run_args+=(--mount "type=bind,source=$host_mount,target=$host_mount")
done
if [[ $workspace != "$host_workspace" && $workspace != "$host_workspace/"* ]]; then
  run_args+=(--mount "type=bind,source=$workspace,target=$workspace")
fi
if [[ -t 0 && -t 1 ]]; then
  run_args+=(-it)
else
  run_args+=(-i)
fi

# Share the complete state directories, including settings and conversation history.
for relative in .tsh .kube .codex .claude .pi .cursor .config/gh .config/cursor; do
  if [[ -d "$host_home/$relative" ]]; then
    run_args+=(--mount "type=bind,source=$host_home/$relative,target=$container_home/$relative")
  fi
done

# Cursor's desktop history is separate from its CLI state on macOS.
cursor_desktop_history="$host_home/Library/Application Support/Cursor/User/History"
if [[ -d $cursor_desktop_history ]]; then
  mkdir -p "$host_workspace/.config/Cursor/User"
  run_args+=(--mount "type=bind,source=$cursor_desktop_history,target=$container_home/.config/Cursor/User/History,readonly")
fi

if $enable_docker; then
  socket=/var/run/docker.sock
  if [[ ! -S $socket ]]; then
    echo "Docker socket unavailable: $socket" >&2
    exit 1
  fi
  if [[ $(uname -s) == Darwin ]]; then
    # OrbStack presents the mounted socket as root:root inside Linux containers.
    socket_gid=0
  else
    socket_gid=$(stat -c %g "$socket")
  fi
  run_args+=(
    --mount "type=bind,source=$socket,target=/var/run/docker.sock"
    --env "DOCKER_SOCKET_GID=$socket_gid"
  )
fi

exec docker "${run_args[@]}" "$image" "$@"
