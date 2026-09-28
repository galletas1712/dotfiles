FROM docker:cli AS docker_cli
FROM golang:latest AS go
FROM ghcr.io/astral-sh/uv:latest AS uv
# Node LTS includes npm and npx for agents and ordinary projects.
FROM node:lts-slim

COPY --from=docker_cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker_cli /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins
COPY --from=go /usr/local/go /usr/local/go
COPY --from=uv /uv /uvx /usr/local/bin/
ENV PATH="/usr/local/go/bin:${PATH}"

# A new value each day makes package installation check for current releases.
ARG REFRESH
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl file fzf git gosu jq less openssh-client \
      ripgrep sudo zsh && \
    rm -rf /var/lib/apt/lists/*

# GitHub's and Teleport's official APT repositories provide current packages.
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    curl -fsSL https://apt.releases.teleport.dev/gpg \
      -o /etc/apt/keyrings/teleport-archive-keyring.asc && \
    . /etc/os-release && \
    echo "deb [signed-by=/etc/apt/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/${ID} ${VERSION_CODENAME} stable/rolling" \
      > /etc/apt/sources.list.d/teleport.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh teleport && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
RUN kubectl_version=$(curl -fsSL https://dl.k8s.io/release/stable.txt) && \
    curl -fsSL "https://dl.k8s.io/release/$kubectl_version/bin/linux/$TARGETARCH/kubectl" \
      -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 \
      -o /tmp/get-helm.sh && \
    bash /tmp/get-helm.sh && \
    rm /tmp/get-helm.sh

RUN curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${TARGETARCH}.tar.gz" \
      -o /tmp/k9s.tar.gz && \
    tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s && \
    rm /tmp/k9s.tar.gz

RUN curl -fsSL "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-${TARGETARCH}" \
      -o /usr/local/bin/vcluster && \
    chmod +x /usr/local/bin/vcluster

RUN npm install --global --no-audit --no-fund \
      @openai/codex @anthropic-ai/claude-code && \
    npm install --global --no-audit --no-fund --ignore-scripts \
      @earendil-works/pi-coding-agent

# Keep the container's Linux Cursor executable separate from shared home files.
RUN mkdir -p /opt/cursor-agent-home && \
    curl -fsSL https://cursor.com/install -o /tmp/install-cursor.sh && \
    HOME=/opt/cursor-agent-home bash /tmp/install-cursor.sh && \
    ln -s /opt/cursor-agent-home/.local/bin/cursor-agent /usr/local/bin/cursor-agent && \
    ln -s /opt/cursor-agent-home/.local/bin/agent /usr/local/bin/agent && \
    rm /tmp/install-cursor.sh

WORKDIR /workspace
COPY --chmod=0755 entrypoint.sh /usr/local/bin/dev-entrypoint
ENTRYPOINT ["dev-entrypoint"]
CMD ["zsh"]
