#!/usr/bin/env bash
#
# Bootstrap a fresh Amazon Linux 2023 (Graviton/arm64) host with the
# tools the lite dotfiles assume. Idempotent — re-runs are safe.
#
# Usage (run ON THE REMOTE, not the laptop):
#   curl -fsSL https://… | bash         # or:
#   scp install-remote.sh ec2_host:~/  && ssh ec2_host 'bash ~/install-remote.sh'

set -euo pipefail

ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]]; then
    echo "warn: this script is tuned for aarch64 (Graviton). Detected: $ARCH" >&2
fi

echo "==> dnf packages"
# AL2023 ships curl-minimal preinstalled; installing the full `curl` package
# triggers a conflict that requires --allowerasing. curl-minimal supports
# everything we use (-fSL, redirect-follow), so just skip it.
sudo dnf install -y zsh git tmux tar gzip

# ── neovim ──────────────────────────────────────────────────────────────
if ! command -v nvim >/dev/null 2>&1; then
    echo "==> Installing neovim (arm64 prebuilt)"
    curl -fSL \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz \
        -o /tmp/nvim.tar.gz
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    sudo ln -sf /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
    rm /tmp/nvim.tar.gz
fi

# ── ripgrep ─────────────────────────────────────────────────────────────
if ! command -v rg >/dev/null 2>&1; then
    echo "==> Installing ripgrep (arm64 prebuilt)"
    RG_VER=$(curl -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest \
             | grep -oP '"tag_name":\s*"\K[^"]+')
    curl -fSL \
        "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/ripgrep-${RG_VER}-aarch64-unknown-linux-gnu.tar.gz" \
        -o /tmp/rg.tar.gz
    sudo tar -C /opt -xzf /tmp/rg.tar.gz
    sudo ln -sf "/opt/ripgrep-${RG_VER}-aarch64-unknown-linux-gnu/rg" /usr/local/bin/rg
    rm /tmp/rg.tar.gz
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
if ! command -v docker >/dev/null 2>&1; then
    echo "==> Installing docker engine"
    sudo dnf install -y docker
fi
# Always ensure the daemon is enabled at boot and currently running.
# `enable --now` is a no-op if both are already true, so re-runs are safe.
sudo systemctl enable --now docker
# Add current user to docker group (idempotent — `usermod -aG` is a no-op
# if the user is already in the group). Takes effect after re-login.
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    echo "==> Adding $USER to docker group (needs re-login)"
    sudo usermod -aG docker "$USER"
fi

# ── docker compose plugin (v2) ──────────────────────────────────────────
# AL2023 doesn't ship the compose plugin. Drop the binary into the
# user-scope CLI plugins dir so `docker compose ...` works.
COMPOSE_PLUGIN="$HOME/.docker/cli-plugins/docker-compose"
if [[ ! -x "$COMPOSE_PLUGIN" ]]; then
    echo "==> Installing docker compose plugin (arm64 prebuilt)"
    COMPOSE_VER=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
                 | grep -oP '"tag_name":\s*"\K[^"]+')
    mkdir -p "$(dirname "$COMPOSE_PLUGIN")"
    curl -fSL \
        "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-linux-${ARCH}" \
        -o "$COMPOSE_PLUGIN"
    chmod +x "$COMPOSE_PLUGIN"
fi

# ── default shell ───────────────────────────────────────────────────────
# `chsh` isn't installed on AL2023 by default (lives in util-linux-user).
# `usermod` is in shadow-utils, which is preinstalled — same effect.
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "==> Setting zsh as login shell (you'll need to log out + back in)"
    sudo usermod -s "$(command -v zsh)" "$USER"
fi

echo
echo "==> Done. Versions:"
nvim --version | head -1
rg --version | head -1
"$HOME/.fzf/bin/fzf" --version
docker --version
# `docker compose version` would need the docker group to be active, which
# only happens after re-login. Inspect the plugin directly instead.
"$COMPOSE_PLUGIN" version
echo
echo "Log out and back in so zsh becomes the default shell"
echo "AND so your user picks up the docker group (needed for non-sudo 'docker ...')."
