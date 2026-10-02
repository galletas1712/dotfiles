# Shared development container

The host keeps the container engine, chezmoi, shell tools, `gh`, `jq`, `zmx`, and host copies of Codex and Claude Code. This image provides Linux copies of Codex, Claude Code, Pi and Cursor Agent; P4 CLI; the shared Kubernetes clients `tsh`, `kubectl`, `helm`, `k9s` and `vcluster`; and Node LTS with `npm`/`npx`, `uv`, and a Go starting toolchain. `kind`, `minikube`, `kubebuilder` and `kubelogin` are absent. Project dependencies and any additional language runtimes belong in each project's own files or image.

| Work | Shared image | Per project |
| --- | --- | --- |
| Python | `uv` executable; no chosen development Python | `.python-version` and `pyproject.toml` choose Python; `uv.lock` and `.venv` hold that project's dependencies. `uv sync` downloads the requested interpreter if needed. Interpreters are cached by version in the container home, rather than copied into every project. |
| JavaScript/TypeScript | Node LTS, `npm` and `npx` for the agents and ordinary projects | `package.json`, `package-lock.json`, local `node_modules` and a local `typescript` dev dependency. Use `npm ci` and project scripts such as `npm run typecheck`; do not install TypeScript globally. A project needing another Node major version uses its own image. |
| Go | Current `go` command as a starting toolchain | `go.mod`/`go.sum` record modules and Go requirements; Go can download a newer toolchain when a module requests one. A project requiring an exact older toolchain uses its own image. Keep Go tools as module tool dependencies where supported. |

The shared image follows current releases on rebuild. Project locks and runtime requirements stay stable until the project deliberately updates them. This lets the common shell upgrade without silently changing application dependencies. C/C++ compilers and headers are added in projects that need native builds. Ignore project `.venv` and `node_modules` directories in Git, and recreate them separately on Mac's Linux ARM guest and Odin's Linux x86 guest. [uv Python versions](https://docs.astral.sh/uv/concepts/python-versions/), [uv projects](https://docs.astral.sh/uv/guides/projects/), [npm clean install](https://docs.npmjs.com/cli/commands/npm-ci/), [TypeScript project install](https://www.typescriptlang.org/download/), [Go toolchains](https://go.dev/doc/toolchain)

Run `bash dev-shell.sh` to start in `~/workspace`, or pass an absolute project path. Add `-- command` to run a command directly. Use `--docker` to access the host Docker engine; images and sibling containers then live on the host. On Mac, start OrbStack first. Host networking is enabled.

The entire host home is mounted read-write at its original absolute path, which is also the container user's home. Projects, dotfiles, credentials, agent histories, and BB data are shared automatically. Existing symlinks within the home keep working. Use `--mount-host /absolute/path` for symlink targets or other data outside the home. A selected project outside the home is mounted automatically at the same path.

The container creates a user with the host username and numeric IDs, with passwordless sudo. Image tools are installed under `/usr/local` and `/opt`, never into the mounted home. Container startup does not install packages into the home or rewrite Git configuration. Applications may still write their normal settings, histories, caches, and project dependencies to the shared home. The shared zsh configuration gives image executables precedence over host binaries.

The image follows current releases, checks base images on each launch, and refreshes package installation daily. This is a repeatable setup rather than a version-locked build. Runtime caches and host configuration also remain mutable.

On macOS, sharing Docker configuration does not make the macOS Keychain helper executable in Linux. Registry authentication that depends on that helper requires a Linux-compatible credential arrangement. Cloud credentials are shared, but their CLIs are not installed solely for that reason. Cursor desktop history remains available at its original host path; sharing it does not convert it into Linux Cursor desktop history.

The launcher refuses a Linux build when either the workspace or Docker filesystem has less than 20 GiB free; that is a startup check, not a limit on files written during a session. Daily refreshes can accumulate Docker build cache over time; the launcher does not run a global Docker prune, which could remove unrelated caches or images.
