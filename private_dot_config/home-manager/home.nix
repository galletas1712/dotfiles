{ config, pkgs, lib, ... }:

{
  home.username = "schwinns";
  home.homeDirectory = "/home/schwinns";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # Languages & runtimes
    nodejs
    go
    gopls
    zig
    bun
    uv
    rustup
    python3

    # Build tools
    gcc
    # Lower priority to avoid bin/cc conflict with gcc
    (lib.setPrio 20 clang)
    llvmPackages.llvm
    gnumake
    cmake
    ninja
    ccache
    pkg-config
    protobuf

    # CLI tools
    just
    ripgrep
    jq
    starship
    gh
    chezmoi
    tmux
    htop
    vim

    # Kubernetes
    kubectl
    k9s
    kubernetes-helm
    kind
    minikube
    kubebuilder
    kubelogin

    # Debugging
    gdb
    strace
    criu
    py-spy

    # Networking
    nmap
    tcpdump
    socat
    mosh
    eternal-terminal

    # Servers
    etcd
    nats-server
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.home-manager.enable = true;
}
