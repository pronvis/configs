#!/usr/bin/env bash
#
# Bootstrap a fresh apt-based host (Ubuntu/Debian) with the tools the lite
# dotfiles assume. Works on both x86_64 and aarch64. Idempotent.
#
# Usage (run ON THE REMOTE, not the laptop):
#   scp install-remote-apt.sh host:~/ && ssh host 'bash ~/install-remote-apt.sh'

set -euo pipefail

ARCH=$(uname -m)
# Map uname arch -> the naming each upstream uses.
case "$ARCH" in
    x86_64)  NVIM_ARCH=x86_64; RG_ARCH=x86_64 ;;
    aarch64) NVIM_ARCH=arm64;  RG_ARCH=aarch64 ;;
    *) echo "error: unsupported arch '$ARCH'" >&2; exit 1 ;;
esac
DPKG_ARCH=$(dpkg --print-architecture)   # amd64 / arm64 — for the docker apt repo

echo "==> apt packages (arch: $ARCH)"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y zsh git tmux tar gzip curl ca-certificates rsync

# ── neovim ──────────────────────────────────────────────────────────────
# Ubuntu's apt nvim is too old for the lite config; use the prebuilt tarball.
if ! command -v nvim >/dev/null 2>&1; then
    echo "==> Installing neovim (${NVIM_ARCH} prebuilt)"
    curl -fSL \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz" \
        -o /tmp/nvim.tar.gz
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    sudo ln -sf "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim
    rm /tmp/nvim.tar.gz
fi

# ── ripgrep ─────────────────────────────────────────────────────────────
# apt ships ripgrep on Ubuntu 24.04, so prefer it; fall back to prebuilt.
if ! command -v rg >/dev/null 2>&1; then
    echo "==> Installing ripgrep"
    sudo apt-get install -y ripgrep || {
        echo "==> apt ripgrep unavailable; using ${RG_ARCH} prebuilt"
        RG_VER=$(curl -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest \
                 | grep -oP '"tag_name":\s*"\K[^"]+')
        curl -fSL \
            "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/ripgrep-${RG_VER}-${RG_ARCH}-unknown-linux-musl.tar.gz" \
            -o /tmp/rg.tar.gz
        sudo tar -C /opt -xzf /tmp/rg.tar.gz
        sudo ln -sf "/opt/ripgrep-${RG_VER}-${RG_ARCH}-unknown-linux-musl/rg" /usr/local/bin/rg
        rm /tmp/rg.tar.gz
    }
fi

# ── fzf ─────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.fzf" ]]; then
    echo "==> Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
fi

# ── zsh plugins (autosuggestions + syntax highlighting) ─────────────────
# Standalone clones — no oh-my-zsh needed; sourced from lite/zshrc.
if [[ ! -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    echo "==> Installing zsh-autosuggestions"
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
        "$HOME/.zsh/zsh-autosuggestions"
fi
if [[ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]]; then
    echo "==> Installing zsh-syntax-highlighting"
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
        "$HOME/.zsh/zsh-syntax-highlighting"
fi

# ── docker ──────────────────────────────────────────────────────────────
# Install Docker Engine + compose plugin from Docker's official apt repo.
if ! command -v docker >/dev/null 2>&1; then
    echo "==> Installing docker engine (official apt repo, arch ${DPKG_ARCH})"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=${DPKG_ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin
fi
# Always ensure the daemon is enabled at boot and currently running.
sudo systemctl enable --now docker
# Add current user to docker group (idempotent). Takes effect after re-login.
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    echo "==> Adding $USER to docker group (needs re-login)"
    sudo usermod -aG docker "$USER"
fi

# ── default shell ───────────────────────────────────────────────────────
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "==> Setting zsh as login shell (you'll need to log out + back in)"
    sudo chsh -s "$(command -v zsh)" "$USER"
fi

echo
echo "==> Done. Versions:"
nvim --version | head -1
rg --version | head -1
"$HOME/.fzf/bin/fzf" --version
docker --version
docker compose version 2>/dev/null || echo "(docker compose: available after re-login)"
echo
echo "Log out and back in so zsh becomes the default shell"
echo "AND so your user picks up the docker group (needed for non-sudo 'docker ...')."
