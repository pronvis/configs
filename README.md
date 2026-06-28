# dotfiles

macOS configuration, managed as symlinks and bootstrapped by `./install.sh`.

## Bootstrap

```sh
./install.sh             # everything: tools + links + keys
./install.sh links       # just the config symlinks
./install.sh links keys  # symlinks + GPG/SSH key
./install.sh tools       # CLI tools + app bootstrap (Mason, tmux plugins)
DRY_RUN=1 ./install.sh   # preview every action, change nothing
```

Phases run in a dependency-safe order regardless of how they're passed:

- **tools** — Homebrew, rustup, nvm + node, oh-my-zsh, the brew & cargo
  packages, and the zsh / base16 / tmux plugin clones. Then app-internal
  bootstrap: headless Mason LSP install and tmux (TPM) plugin install.
- **links** — symlinks every config into place. Any existing target is moved to
  `<name>.bak` (timestamped if a `.bak` already exists) before linking, so
  nothing is ever destroyed.
- **keys** — decrypts + imports the GPG key from its encrypted backup and
  registers its authentication subkey with gpg-agent so it also serves SSH.

The script is idempotent — safe to re-run. Tool installs are best-effort: a
single failed install warns and continues.

## Manual steps (not automated)

- **Nerd Font** (for icons in nvim-tree): install a patched font from
  <https://www.nerdfonts.com/>. Backup: `~/Yandex.Disk.localized/fonts/JetBrainsMono_hacked.zip`.
- **SSH cutover**: `./install.sh keys` prints your SSH public key — add it to
  each server's `~/.ssh/authorized_keys`, verify login, then retire the old key.

## Keys

A single **Ed25519 GPG key** serves both signing/encryption **and** SSH (through
its authentication subkey + gpg-agent — `enable-ssh-support` is set in
`gpg-agent.conf`, and `zsh/zshrc_conf.zshrc` points `SSH_AUTH_SOCK` at the
agent). `./install.sh keys` restores it from the encrypted backup and wires SSH.

The key is backed up passphrase-encrypted (`gpg -c`); the passphrase is in 1Password.

```bash
# create the encrypted backup
gpg --export-secret-keys "$FINGERPRINT" \
  | gpg -c --cipher-algo AES256 --s2k-mode 3 --s2k-digest-algo SHA512 --s2k-count 65011712 \
      -o ~/Yandex.Disk.localized/PGP/ed25519_key.gpg

# restore it (what `./install.sh keys` does)
gpg -d ~/Yandex.Disk.localized/PGP/ed25519_key.gpg | gpg --import
```

- Test signing: `echo "test" | gpg --clearsign`
- Test SSH identity: `ssh-add -L` (should list the Ed25519 auth subkey)

### Troubleshooting: gpg/SSH/signed commits hang

If `git pull`, signed commits (`gcsm`), or any gpg command "does nothing" while
`git status` works fine, gpg-agent can't start. Most common cause is a Homebrew
dependency mismatch after `brew upgrade` — e.g. `gnupg` built against an old
`libassuan` soname:

```
gpg-agent: Library not loaded: .../libassuan.0.dylib  # agent aborts on launch
```

Fix by rebuilding the gpg stack against current libs:

```bash
brew upgrade gnupg          # or: brew reinstall gnupg
pkill -9 -f gpg-agent       # drop the wedged agent; it respawns clean
gpg-agent --gpgconf-test    # should print nothing + exit 0
gpg-connect-agent /bye      # should say "connection to the agent established"
```

Also ensure `pinentry-mac` is installed (it's in `BREW_PACKAGES` and referenced
by `gpg-agent.conf`); `pinentry-curses` hangs inside other TUIs.

## NeoVim

LSP servers are installed automatically via Mason during `./install.sh tools`:
marksman, clangd, lua-language-server, html-lsp, typescript-language-server,
codelldb.

# Remote Servers

### First time on the server (one command):
Detects the server's architecture, runs the matching installer, and pushes the dotfiles:
```
./lite/provision-remote.sh host
```
`host` is an ssh-config alias or `user@host`.

<details><summary>What it does / manual equivalent</summary>

It picks the installer by the remote's package manager (each installer is
arch-aware and handles both x86_64 and aarch64):
- `apt` (Ubuntu/Debian) → `install-remote-apt.sh`
- `dnf` (Amazon Linux 2023 / Fedora / RHEL) → `install-remote-dnf.sh`

```
scp ./lite/install-remote-apt.sh host:~/
ssh host 'bash ~/install-remote-apt.sh'
./lite/dot-push.sh host
```
</details>

### Push configs (run any time):

#### dry run
`DRY_RUN=1 ./lite/dot-push.sh`

#### execute
`./lite/dot-push.sh`

## SSH config

add smth like that to `~/.ssh/config`
```
Host ec2_how-tmux
    HostName hostname_or_ip_address
    User ec2-user
    RemoteCommand tmux -u new-session -A -s main
    RequestTTY yes
```
The GPG auth subkey is offered automatically by gpg-agent, so no `IdentityFile`
line is needed.
