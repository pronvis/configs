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

## NeoVim

LSP servers are installed automatically via Mason during `./install.sh tools`:
marksman, clangd, lua-language-server, html-lsp, typescript-language-server,
codelldb.

# Remote Servers

### First time on the server (install missing tools):
```
scp ./lite/install-remote.sh ec2_host:~/
ssh ec2_host 'bash ~/install-remote.sh'
./lite/dot-push.sh ec2_host
```

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
