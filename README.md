# Installation steps
First of all install those usefull tools:
- install [brew](https://brew.sh/)
- install [nvm](https://github.com/nvm-sh) and rust
- `nvm install node`
- `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- `brew install tmux`
- `brew install neovim`
- `brew install fd`
- `brew install rg`
- `brew install go`
- `brew install autojump`
- `brew install fzf`
- `cargo install proximity-sort`
- `cargo install cargo-add`
- `cargo install cargo-whatfeatures`
- `cargo install --git https://github.com/davidpdrsn/cargo-docserver.git`
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
- `ln -s $PWD/alacritty/alacritty.toml ~/.alacritty.toml`
- `use gitconfig from your 1TB storage` (private data)

# NeoVim

In Mason (`:Mason`) install:
- marksman
- clangd
- lua-language-server
- html-lsp
- typescript-language-server
- codelldb

# GPG

1. Import private key: `gpg --import ${path_to_priv_key}`
2. `export GPG_TTY=$(tty)`

Now `gcsm "commit message"` should work fine, test it with: `echo "test" | gpg --clearsign`

# SSH

Encrypted main key is located in "your 1TB storage". To decrypt it use: `gpg -d ${path_to_gpg_key} > ~/.ssh/id_rsa`

# VPN

- `brew install openvpn`
- `sudo openvpn --config ${path_to_yandex_disk}/VPN/nexus.ovpn`
