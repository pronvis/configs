#!/usr/bin/env bash
#
# Bootstrap this macOS machine from the dotfiles repo.
#
# Phases (run any subset; no args = all, always in dependency-safe order):
#   tools  - install CLI tools (brew, rustup, nvm, oh-my-zsh, brew/cargo pkgs,
#            plugin clones) + app-internal bootstrap (Mason LSPs, tmux plugins)
#   links  - create the config symlinks (existing files are backed up first)
#   keys   - decrypt + import the GPG key and wire its auth subkey to SSH
#
# Usage:
#   ./install.sh                 # everything
#   ./install.sh links           # just symlinks
#   ./install.sh links keys      # symlinks + keys
#   ./install.sh tools           # installs + app bootstrap only
#   DRY_RUN=1 ./install.sh       # preview every action, change nothing
#
# Conflict policy for links: if a target exists, it's moved to <name>.bak
# (timestamped if a .bak already exists) before the symlink is created.
#
# Idempotent: safe to re-run. Tool installs are best-effort — a single failed
# install warns and continues rather than aborting the whole run.

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN="${DRY_RUN:-0}"               # DRY_RUN=1 ./install.sh — preview, change nothing

# ═════════════════════════════════════════════════════════════════════════
# Constants — WHAT to install/link. All data lives here; logic is below.
# ═════════════════════════════════════════════════════════════════════════

# Homebrew formulae.
# Note: pinentry-mac gives a native macOS passphrase dialog (and Keychain
# storage). Without it, gpg-agent falls back to pinentry-curses, whose TUI
# breaks inside other TUIs (e.g. Claude Code) and hangs gpg/SSH/signed commits.
# It must match the `pinentry-program` line in gpg-agent.conf.
BREW_PACKAGES=(
    tmux neovim fd ripgrep go autojump fzf cargo-binstall python3 awscli gnupg pinentry-mac
)

# Homebrew casks (GUI apps / fonts). font-d2coding = monospace Korean font,
# routed to Hangul ranges in kitty.conf so Korean text aligns cleanly.
BREW_CASKS=(
    font-d2coding
)

# Cargo installs, as "binary-to-check | cargo subcommand and args".
# (Unified so git/binstall variants live in the same list as plain installs.)
CARGO_INSTALLS=(
    "proximity-sort|install proximity-sort"
    "cargo-add|install cargo-add" # now built into cargo; harmless if redundant
    "cargo-whatfeatures|install cargo-whatfeatures"
    "cargo-docserver|install --git https://github.com/davidpdrsn/cargo-docserver.git"
    "tree-sitter|binstall -y tree-sitter-cli"
)

# Global npm packages. These live per-node-version, so `nvm install node`
# bumping to a newer node orphans them — re-running tools reinstalls them
# under the current default node.
NPM_GLOBALS=(
    "@fission-ai/openspec@latest"
)

# Mason LSP servers (installed headless via nvim).
MASON_PACKAGES=(
    marksman clangd lua-language-server html-lsp typescript-language-server codelldb
)

# Git repos to clone, as "url | destination".
GIT_CLONES=(
    "https://github.com/zsh-users/zsh-autosuggestions|${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git|${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    "https://github.com/tmux-plugins/tpm|$HOME/.tmux/plugins/tpm"
)

# Directories to create before linking.
LINK_DIRS=(
    "$HOME/.zsh_sessions"
    "$HOME/.zsh_functions"
    "$HOME/.vim/undodir"
    "$HOME/.config"
    "$HOME/.config/kitty"
    "$HOME/bin"
    "$HOME/.claude/hooks"
    "$HOME/.claude/rules/rust/"
    "$HOME/.claude/commands"
    "$HOME/.claude/skills"
)

# Directories that must be mode 0700.
SECURE_DIRS=(
    "$HOME/.gnupg"
    "$HOME/.ssh"
)

# Config symlinks, as "source | destination". A relative source is resolved
# against the repo; an absolute source is used as-is.
LINKS=(
    "tmux/tmux.conf|$HOME/.tmux.conf"
    "nvim|$HOME/.config/nvim"
    "zsh/zshrc_conf.zshrc|$HOME/.zshrc"
    "git/global_gitignore|$HOME/.gitignore"
    "git/gitconfig|$HOME/.gitconfig"
    "gpg-agent.conf|$HOME/.gnupg/gpg-agent.conf"
    "alacritty/alacritty.toml|$HOME/.alacritty.toml"
    "kitty/kitty.conf|$HOME/.config/kitty/kitty.conf"
    "scripts|$HOME/bin/scripts"
    "claude/settings.json|$HOME/.claude/settings.json"
    "claude/statusline-command.sh|$HOME/.claude/statusline-command.sh"
    "ssh/config|$HOME/.ssh/config"
)

# Directory-contents symlinks, as "source dir | destination dir". Every entry
# directly inside the repo source dir is linked into the destination dir
# (which is a real, shared dir — e.g. ~/.claude/* also holds plugin files, so
# we can't link the whole dir). Add files to the repo dir and they're picked
# up automatically — no need to edit this script.
LINK_GLOBS=(
    "claude/commands|$HOME/.claude/commands"
    "claude/skills|$HOME/.claude/skills"
    "claude/hooks|$HOME/.claude/hooks"
    "claude/rules/rust|$HOME/.claude/rules/rust"
)

# Encrypted GPG key backup to import.
GPG_KEY_BACKUP="GPG/ed25519_key.gpg"

# ═════════════════════════════════════════════════════════════════════════
# Pure helpers — compute or query only, no side effects.
# ═════════════════════════════════════════════════════════════════════════

have() { command -v "$1" >/dev/null 2>&1; }

# Resolve a link source: absolute paths pass through, relative ones join $REPO.
resolve_src() { case "$1" in /*) printf '%s' "$1" ;; *) printf '%s/%s' "$REPO" "$1" ;; esac; }

# True if $2 is already a symlink pointing at $1.
is_linked() { [[ -L "$2" && "$(readlink "$2")" == "$1" ]]; }

# Echo the backup path for $1: "<dst>.bak", or timestamped if that's taken.
next_backup_path() {
    local bak="$1.bak"
    [[ -e "$bak" || -L "$bak" ]] && bak="$1.bak.$(date +%Y%m%d%H%M%S)"
    printf '%s' "$bak"
}

# Echo the fingerprint of the key carrying an authentication subkey (correct
# even when other keys are present in the keyring).
key_fpr_with_auth() {
    gpg --list-keys --with-colons --with-fingerprint 2>/dev/null | awk -F: '
        $1=="pub"              { primary="" }
        $1=="fpr" && !primary  { primary=$10 }
        $1=="sub" && $12 ~ /a/ { print primary; exit }'
}

# Echo the keygrip of the authentication subkey (capabilities field == 'a').
auth_subkey_keygrip() {
    gpg --list-keys --with-keygrip --with-colons 2>/dev/null | awk -F: '
        $1=="pub" || $1=="sub" { auth = ($12 ~ /a/) }
        $1=="grp" && auth      { print $10 }'
}

# ═════════════════════════════════════════════════════════════════════════
# Output + execution helpers (side effects).
# ═════════════════════════════════════════════════════════════════════════

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '   \033[1;32mok\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
dry()  { printf '   \033[1;36mdry\033[0m %s\n' "$*"; }

# Execute a command, or in dry-run just print what would run.
run() { if [[ "$DRY_RUN" == 1 ]]; then dry "$*"; else "$@"; fi; }
# Like run, but best-effort: warn on failure instead of aborting the script.
try() { if [[ "$DRY_RUN" == 1 ]]; then dry "$*"; elif ! "$@"; then warn "step failed: $*"; fi; }

# ═════════════════════════════════════════════════════════════════════════
# Operations — each takes its data as arguments.
# ═════════════════════════════════════════════════════════════════════════

ensure_dirs()        { local d; for d in "$@"; do run mkdir -p "$d"; done; }
ensure_secure_dirs() { local d; for d in "$@"; do run mkdir -p "$d"; run chmod 700 "$d"; done; }

# args: formulae
install_brew() {
    info "Tools: brew formulae"
    local f
    for f in "$@"; do
        brew list --versions "$f" >/dev/null 2>&1 && { ok "brew: $f"; continue; }
        try brew install "$f"
    done
}

# args: cask names
install_brew_casks() {
    info "Tools: brew casks"
    local c
    for c in "$@"; do
        brew list --cask --versions "$c" >/dev/null 2>&1 && { ok "cask: $c"; continue; }
        try brew install --cask "$c"
    done
}

# args: "binary | cargo subcommand and args"
install_cargo() {
    info "Tools: cargo crates"
    have cargo || { warn "cargo unavailable; skipping cargo crates"; return; }
    local spec bin args
    for spec in "$@"; do
        IFS='|' read -r bin args <<<"$spec"
        have "$bin" && { ok "cargo: $bin"; continue; }
        # shellcheck disable=SC2086
        try cargo $args
    done
    try rustup component add clippy
}

# args: npm package specs (e.g. "@scope/pkg@latest")
install_npm_globals() {
    info "Tools: global npm packages"
    have npm || { warn "npm unavailable; skipping global npm packages"; return; }
    local pkg
    for pkg in "$@"; do
        try npm install -g "$pkg"
    done
}

# args: "url | destination"
clone_repos() {
    info "Tools: plugin clones"
    local spec url dest
    for spec in "$@"; do
        IFS='|' read -r url dest <<<"$spec"
        [[ -d "$dest" ]] && { ok "clone: $dest"; continue; }
        run mkdir -p "$(dirname "$dest")"
        try git clone --depth 1 "$url" "$dest"
    done
}

# Create one symlink, backing up an existing target first.
link_one() { # $1 = source spec, $2 = destination
    local src dst bak
    src="$(resolve_src "$1")"
    dst="$2"
    [[ -e "$src" ]] || { warn "link source missing, skipping: $src"; return; }
    # SSH refuses a config that is group/world-writable; enforce strict perms
    # on the real file (the symlink target) so `git pull` over SSH works.
    case "$dst" in
        "$HOME/.ssh/"*) [[ -e "$src" ]] && run chmod 600 "$src" ;;
    esac
    is_linked "$src" "$dst" && { ok "linked: $dst"; return; }
    run mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        bak="$(next_backup_path "$dst")"
        run mv "$dst" "$bak"
        warn "backed up $dst -> $bak"
    fi
    run ln -s "$src" "$dst"
    ok "linked: $dst -> $src"
}

# args: "source | destination"
create_links() {
    info "Links: symlinks"
    local spec src dst
    for spec in "$@"; do
        IFS='|' read -r src dst <<<"$spec"
        link_one "$src" "$dst"
    done
}

# args: "source dir | destination dir" — links each entry inside the source
# dir into the destination dir (non-recursive). New files are picked up
# automatically on re-run.
link_globs() {
    info "Links: directory contents"
    local spec srcdir dstdir src
    for spec in "$@"; do
        IFS='|' read -r srcdir dstdir <<<"$spec"
        srcdir="$(resolve_src "$srcdir")"
        [[ -d "$srcdir" ]] || { warn "link source dir missing, skipping: $srcdir"; continue; }
        for src in "$srcdir"/*; do
            [[ -e "$src" ]] || continue   # empty dir → glob stays literal
            link_one "$src" "$dstdir/$(basename "$src")"
        done
    done
}

# args: Mason package names
mason_install() {
    if ! have nvim || [[ ! -e "$HOME/.config/nvim" ]]; then
        warn "  nvim or ~/.config/nvim missing — run './install.sh links' first, then re-run"
        return
    fi
    info "  nvim: restoring plugins (locked versions) + installing LSP servers (headless)"
    try nvim --headless "+Lazy! restore" +qa
    try nvim --headless "+MasonInstall $*" +qa
}

install_tmux_plugins() {
    if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" && -e "$HOME/.tmux.conf" ]]; then
        info "  tmux: installing plugins"
        try "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    else
        warn "  TPM or ~/.tmux.conf missing — run './install.sh links' first, then re-run"
    fi
}

# ── key operations (each takes a fingerprint/keygrip argument) ──
trust_key() { # $1 = fingerprint
    [[ -n "$1" ]] || return
    if [[ "$DRY_RUN" == 1 ]]; then
        dry "echo '$1:6:' | gpg --import-ownertrust"
    else
        echo "$1:6:" | gpg --import-ownertrust >/dev/null 2>&1
    fi
}

register_ssh_keygrip() { # $1 = keygrip
    if [[ -z "$1" ]]; then
        warn "no authentication subkey found; SSH-over-GPG not wired"
        return
    fi
    if grep -qs "$1" "$HOME/.gnupg/sshcontrol"; then
        ok "sshcontrol already has the auth keygrip"
    elif [[ "$DRY_RUN" == 1 ]]; then
        dry "echo '$1' >> ~/.gnupg/sshcontrol"
    else
        echo "$1" >>"$HOME/.gnupg/sshcontrol"
        ok "registered auth keygrip in sshcontrol"
    fi
    run gpgconf --kill gpg-agent
}

print_ssh_pubkey() { # $1 = fingerprint
    [[ -n "$1" ]] || return
    info "SSH public key — add this to each server's ~/.ssh/authorized_keys:"
    gpg --export-ssh-key "$1" 2>/dev/null || true
}

# ── package-manager bootstrap (imperative env setup) ──
setup_brew() {
    info "Tools: Homebrew"
    if ! have brew; then
        try /bin/bash -c \
            'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    have brew
}

setup_rustup() {
    if ! have rustup; then
        info "Installing rustup"
        try /bin/bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    fi
    # shellcheck disable=SC1091
    [[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
    return 0
}

setup_nvm_node() {
    if [[ ! -d "$HOME/.nvm" ]]; then
        info "Installing nvm"
        try /bin/bash -c \
            'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
    fi
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
    # Install the latest LTS and make new shells default to it. Using LTS
    # (not bleeding-edge `node`) keeps the version stable and avoids orphaning
    # globally-installed npm packages on every run.
    if type nvm >/dev/null 2>&1; then
        try nvm install --lts
        try nvm alias default 'lts/*'
    fi
    return 0
}

setup_oh_my_zsh() {
    [[ -d "$HOME/.oh-my-zsh" ]] && return 0
    info "Installing oh-my-zsh"
    # KEEP_ZSHRC so it never clobbers our symlinked ~/.zshrc
    try /bin/bash -c \
        'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    return 0
}

# ═════════════════════════════════════════════════════════════════════════
# Phases — wire the data to the operations.
# ═════════════════════════════════════════════════════════════════════════

phase_tools() {
    info "Tools: package managers"
    setup_brew || { warn "brew unavailable; skipping brew/cargo installs"; return; }
    setup_rustup
    setup_nvm_node
    setup_oh_my_zsh

    install_brew        "${BREW_PACKAGES[@]}"
    install_brew_casks  "${BREW_CASKS[@]}"
    install_cargo       "${CARGO_INSTALLS[@]}"
    install_npm_globals "${NPM_GLOBALS[@]}"
    clone_repos         "${GIT_CLONES[@]}"
}

phase_links() {
    info "Links: directories"
    ensure_dirs        "${LINK_DIRS[@]}"
    ensure_secure_dirs "${SECURE_DIRS[@]}"
    create_links       "${LINKS[@]}"
    link_globs         "${LINK_GLOBS[@]}"
}

phase_keys() {
    info "Keys: import GPG key + wire SSH"
    # Resolve against the repo so it works regardless of the current directory.
    local enc
    enc="$(resolve_src "$GPG_KEY_BACKUP")"
    if [[ ! -f "$enc" ]]; then
        warn "encrypted key not found: $enc — skipping keys"
        return
    fi
    ensure_secure_dirs "$HOME/.gnupg"

    info "Decrypting + importing key (enter the backup passphrase when prompted)"
    if [[ "$DRY_RUN" == 1 ]]; then
        dry "gpg --decrypt '$enc' | gpg --import"
    elif gpg --decrypt "$enc" | gpg --import; then
        ok "GPG key imported"
    else
        warn "import failed (wrong passphrase?) — re-run: ./install.sh keys"
        return
    fi

    local fpr grip
    fpr="$(key_fpr_with_auth)"
    grip="$(auth_subkey_keygrip)"

    trust_key "$fpr"
    register_ssh_keygrip "$grip"
    print_ssh_pubkey "$fpr"
}

# App-internal bootstrap — runs after links so the configs exist. Best-effort.
bootstrap_apps() {
    info "App bootstrap (Mason LSPs, tmux plugins)"
    mason_install "${MASON_PACKAGES[@]}"
    install_tmux_plugins
}

# ═════════════════════════════════════════════════════════════════════════
# Dispatch.
# ═════════════════════════════════════════════════════════════════════════

usage() {
    cat <<'USAGE'
Bootstrap this macOS machine from the dotfiles repo.

Phases (run any subset; no args = all, in dependency-safe order):
  tools  - install CLI tools + app bootstrap (Mason LSPs, tmux plugins)
  links  - create the config symlinks (existing targets backed up first)
  keys   - decrypt + import the GPG key and wire its auth subkey to SSH

Usage:
  ./install.sh                # everything
  ./install.sh links          # just symlinks
  ./install.sh links keys     # symlinks + keys
  DRY_RUN=1 ./install.sh      # preview every action, change nothing
USAGE
}

declare -a want
if [[ $# -eq 0 ]]; then
    want=(tools links keys)
else
    for a in "$@"; do
        case "$a" in
            tools | links | keys) want+=("$a") ;;
            -h | --help) usage; exit 0 ;;
            *) warn "unknown phase: $a"; usage; exit 2 ;;
        esac
    done
fi

wants() { local p; for p in "${want[@]}"; do [[ "$p" == "$1" ]] && return 0; done; return 1; }

[[ "$DRY_RUN" == 1 ]] && info "DRY RUN — no changes will be made (phases: ${want[*]})"

# Canonical order regardless of how args were given; app bootstrap runs last
# (after links) so the headless app steps see the linked configs.
wants tools && phase_tools
wants links && phase_links
wants keys  && phase_keys
wants tools && bootstrap_apps

info "Done."
cat <<'EOF'

Manual steps the script can't do:
  - Install a Nerd Font (icons in nvim-tree): https://www.nerdfonts.com/
  - SSH cutover: add the printed key to servers' authorized_keys, verify login,
    then remove the old key and strip 'IdentityFile ~/.ssh/id_rsa' from ssh config.
  - Log out/in so zsh becomes the default login shell, and open a fresh shell so
    PATH picks up brew/cargo.
EOF
