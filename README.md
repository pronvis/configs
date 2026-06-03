# Installation steps
First of all install those usefull tools:
- install [brew](https://brew.sh/)
- install [nvm](https://github.com/nvm-sh) and rust
- `nvm install node`
- `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- `brew install tmux`
- `brew install neovim`
- `brew install fd`
- `brew install python3`
- `brew install rg`
- `brew install go`
- `brew install autojump`
- `brew install fzf`
- `cargo install proximity-sort`
- `cargo install cargo-add`
- `cargo install cargo-whatfeatures`
- `cargo install --git https://github.com/davidpdrsn/cargo-docserver.git`
- `brew install cargo-binstall`
- `cargo binstall tree-sitter-cli`
- `rustup component add clippy`
- `git clone https://github.com/tinted-theming/base16-shell.git $HOME/.config/base16-shell`
- `git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`
- `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`

## Tmux
- install plugin manager:
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
- inside tmux hit `prefix + I` to install plugins from cfg file that you linked

#### Add special icons
For `nvim-tree/nvim-web-devicons` to show icons you need to install patched font from: `https://www.nerdfonts.com/`
I place it here: `~/Yandex.Disk.localized/fonts/JetBrainsMono_hacked.zip`

# Link Configs
- `mkdir $HOME/.zsh_sessions`
- `mkdir $HOME/.zsh_functions`
- `mkdir -p $HOME/.vim/undodir`
- `mkdir -p $HOME/.config/nvim/scripts/`
- `cd {this_repo_directory}`
- `ln -s $PWD/tmux/tmux.conf ~/.tmux.conf`
- `ln -s $PWD/nvim ~/.config/nvim`
- `ln -s $PWD/zsh/zshrc_conf.zshrc ~/.zshrc`
- `ln -s $PWD/global_gitignore ~/.gitignore`
- `ln -s $PWD/gpg-agent.conf ~/.gnupg/gpg-agent.conf`
- `ln -s $PWD/alacritty/alacritty.toml ~/.alacritty.toml`
- `ln -s $PWD/scripts/ ~/bin/scripts`
- `ln -s $PWD/claude/settings.json ~/.claude/settings.json`
- `ln -s $PWD/claude/statusline-command.sh ~/.claude/statusline-command.sh`
- `ln -s $PWD/claude/hooks/rustfmt.sh ~/.claude/hooks/rustfmt.sh`
- `ln -s ~/Yandex.Disk.localized/ssh/config ~/.ssh/config`
- `ln -s ~/Yandex.Disk.localized/git/gitconfig ~/.gitconfig`

# NeoVim

In Mason (`:Mason`) install:
- marksman
- clangd
- lua-language-server
- html-lsp
- typescript-language-server
- codelldb

# GPG

Key encrypted with:
```bash
gpg --export-secret-keys "$FINGERPRINT" | gpg -c --cipher-algo AES256 --s2k-mode 3 --s2k-digest-algo SHA512 --s2k-count 65011712 -o ~/Yandex.Disk.localized/PGP/ed25519_key.gpg
```
To  decrypt it execute:
```bash
gpg -d ~/Yandex.Disk.localized/PGP/id_ed25519.gpg | gpg --import
```

1. Import private key: `gpg --import ${path_to_priv_key}`
2. `export GPG_TTY=$(tty)`

Now `gcsm "commit message"` should work fine, test it with: `echo "test" | gpg --clearsign`

# SSH

Encrypted main key is located in "your 1TB storage". To decrypt it use: `gpg -d ${path_to_gpg_key} > ~/.ssh/id_rsa`
Or in 1password `Rsa main`

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
    IdentityFile ~/.ssh/id_rsa
    RemoteCommand tmux -u new-session -A -s main
    RequestTTY yes
```
