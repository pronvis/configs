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
- `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`

## Iterm2
#### Iterm2 integration with Unix (tmux, ssh, etc.)
```
curl -L https://iterm2.com/shell_integration/zsh \
-o ~/.iterm2_shell_integration.zsh
```

#### Themes
- atelier-savanna
- bespin
- darktooth
- eighties
- gruvbox-dark-soft
- hopscotch
- irblack
- railscasts
- woodland
- **railscasts**

#### How to import profiles
Just upload your `*.plist` to `~/Library/Preferences`

Notice, that checkbox:
`Load preferences from a custom folder or URL`
in `Preferences - General` (at the bottom) must be disabled.

#### How to import profile in json mode
**(only if your username is 'pronvis')** just try to create link to profile file:
```
ln -s iterm/pronvis_profile.json /Users/pronvis/Library/Application\ Support/iTerm2/DynamicProfiles/pronvis_profile.json
```
If it will not work then [read this](https://www.iterm2.com/documentation-dynamic-profiles.html)
the main info is:
```
{
  "Profiles": [
    {
      "Name": "Example",
      "Guid": "ba19744f-6af3-434d-aaa6-0a48e0969958"
    }
  ]
}
```

When you export profile it creates json with "name" and "guid" field, so just around it with:
```
{
  "Profiles": [
```

#### How to add Scripts
```
cd ~/Library/Application\ Support/iTerm2
ln -s iterm/Scripts Scripts
```

## Tmux
- install plugin manager:
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
- inside tmux hit `prefix + I` to install plugins from cfg file that you linked

## Vim
- `coc.nvim` requires Node.js so install it with `curl -sL install-node.now.sh/lts | sh`
- vim-plug:
```
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
- inside vim `:PlugInstall`

#### Install coc plugins
- download rust-analyzer: `curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-mac -o /usr/local/bin/rust-analyzer-mac; chmod +x /usr/local/bin/rust-analyzer-mac`
- `:CocInstall coc-exporer`
- `:CocInstall coc-json`
- `:CocInstall coc-explorer`
- `:CocInstall coc-rust-analyzer`
- `:CocInstall coc-tsserver`
- `:CocInstall coc-go`
- **for scala** `:CocInstall coc-metals`

# Link Configs
- `mkdir $HOME/.zsh_sessions`
- `mkdir $HOME/.zsh_functions`
- `cd {this_repo_directory}`
- `ln -s $PWD/tmux/tmux.conf ~/.tmux.conf`
- `mkdir -p ~/.config/nvim/scripts/`
- `ln -s $PWD/vim/init.vim ~/.config/nvim/init.vim`
- `ln -s $PWD/vim/spacetab.vim ~/.config/nvim/scripts/spacetab.vim`
- `ln -s $PWD/vim/closetag.vim ~/.config/nvim/scripts/closetag.vim`
- `ln -s $PWD/vim/coc-settings.json ~/.config/nvim/coc-settings.json`
- `ln -s $PWD/vim/functions.vim ~/.config/nvim/functions.vim`
- `ln -s $PWD/iterm/zshrc_conf.zshrc ~/.zshrc`
- `ln -s $PWD/idea/ideavimrc ~/.ideavimrc`
- `ln -s $PWD/global_gitignore ~/.gitignore`
- `ln -s $PWD/alacritty/alacritty.yml ~/.alacritty.yml`
- `use gitconfig from your 1TB storage` (private data)
