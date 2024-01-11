# Installation steps
First of all install those usefull tools:
- `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- `rustup component add clippy`
- `brew install tmux`
- `brew install neovim`
- `brew install fd`
- `brew install rg`
- `brew install go`
- `brew install autojump`
- `cargo install proximity-sort`
- `cargo install cargo-add`
- `cargo install cargo-whatfeatures`
- `cargo install --git https://github.com/davidpdrsn/cargo-docserver.git`
- `git clone https://github.com/tinted-theming/base16-shell.git $HOME/.config/base16-shell`
- `git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`
- `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`
- `pip install pynvim --upgrade`

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
- `ln -s $PWD/alacritty/alacritty.yml ~/.alacritty.yml`
- `use gitconfig from your 1TB storage` (private data)
