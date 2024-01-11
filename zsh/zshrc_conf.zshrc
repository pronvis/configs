export LC_ALL=en_US.UTF-8
export USER_NAME=`whoami`

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
# don't know why those 2 do not works :(
bindkey "^[[H"    beginning-of-line
bindkey "^[[F"    end-of-line

# For autojump
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# Path to your oh-my-zsh installation.
export ZSH=/Users/$USER_NAME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"
ZSH_THEME=""
plugins=(git colored-man-pages pip python brew macos zsh-syntax-highlighting zsh-autosuggestions)

BASE16_SHELL_PATH="$HOME/.config/base16-shell"
[ -n "$PS1" ] && \
  [ -s "$BASE16_SHELL_PATH/profile_helper.sh" ] && \
    source "$BASE16_SHELL_PATH/profile_helper.sh"

# # SET THEME
base16_tomorrow-night-eighties

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$HOME/programs/liquibase:$PATH"
export PATH="$HOME/programs/activator:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/nss/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/usr/local/php5/bin:$PATH"
export PATH="/opt/local/bin:$PATH"
export CARGO_TARGET_DIR="$HOME/rust/rust_build_artifacts"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export PATH="/Applications/OpenSCAD.app/Contents/MacOS/:$PATH"

# you need to install https://vulkan.lunarg.com/sdk/home first
export VULKAN_SDK=$HOME/vulkan_sdk/macOS
export PATH=$VULKAN_SDK/bin:$PATH
export DYLD_LIBRARY_PATH=$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH
export VK_ICD_FILENAMES=$VULKAN_SDK/etc/vulkan/icd.d/MoltenVK_icd.json
export VK_LAYER_PATH=$VULKAN_SDK/etc/vulkan/explicit_layer.d

source $ZSH/oh-my-zsh.sh

fpath+=$HOME/.zsh_functions

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ccache="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder"
alias mydate="date '+DATE: %m/%d/%y%nTIME: %H:%M:%S'"
alias clean="printf '\e]50;ClearScrollback\a'"

export JAVA_OPTS="-Xmx4096m $JAVA_OPTS"

#Commands to fast create/open archives.
#extract myfile.tar to extract archive. pk tar myfile - to create archive
extract () {
 if [ -f $1 ] ; then
 case $1 in
 *.tar.bz2)   tar xjf $1        ;;
 *.tar.gz)    tar xzf $1     ;;
 *.bz2)       bunzip2 $1       ;;
 *.rar)       unrar x $1     ;;
 *.gz)        gunzip $1     ;;
 *.tar)       tar xf $1        ;;
 *.tbz2)      tar xjf $1      ;;
 *.tbz)       tar -xjvf $1    ;;
 *.tgz)       tar xzf $1       ;;
 *.zip)       unzip $1     ;;
 *.Z)         uncompress $1  ;;
 *.7z)        7z x $1    ;;
 *)           echo "I don't know how to extract '$1'..." ;;
 esac
 else
 echo "'$1' is not a valid file"
 fi
}

pk () {
 if [ $1 ] ; then
 case $1 in
 tbz)       tar cjvf $2.tar.bz2 $2      ;;
 tgz)       tar czvf $2.tar.gz  $2       ;;
 tar)      tar cpvf $2.tar  $2       ;;
 bz2)    bzip $2 ;;
 gz)        gzip -c -9 -n $2 > $2.gz ;;
 zip)       zip -r $2.zip $2   ;;
 7z)        7z a $2.7z $2    ;;
 *)         echo "'$1' cannot be packed via pk()" ;;
 esac
 else
 echo "'$1' is not a valid file"
 fi
}

function setjdk() {
  if [ $# -ne 0 ]; then
   removeFromPath '/System/Library/Frameworks/JavaVM.framework/Home/bin'
   if [ -n "${JAVA_HOME+x}" ]; then
    removeFromPath $JAVA_HOME
   fi
   export JAVA_HOME=`/usr/libexec/java_home -v $@`
   export PATH=$JAVA_HOME/bin:$PATH
  fi
 }

 function removeFromPath() {
  export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")
 }

# setjdk "1.7.0_80"
 setjdk "1.8.0_192"

### zsh-autosuggestions ###
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

local ret_status="%(?:%{$fg_bold[green]%}%~ ➜ :%{$fg_bold[red]%}%~ ➜ )"
PROMPT='${ret_status}%{$reset_color%}$(git_prompt_info)'

# Don't share history across tabs
# https://superuser.com/questions/1245273/iterm2-version-3-individual-history-per-tab
unsetopt inc_append_history
unsetopt share_history

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --hidden --files'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

# Fix 'less' italic highlighting in tmux (reason why it is italic is `tmux-256color`)
# https://unix.stackexchange.com/questions/179173/make-less-highlight-search-patterns-instead-of-italicizing-them
#
# It is "xterm-256color", so I don't need it. Actually not always
export LESS_TERMCAP_so=$'\E[30;43m'
export LESS_TERMCAP_se=$'\E[39;49m'

# git branch symbol
local git_branch_symbol="\ue0a0"
# %{ %} - means zero width inside
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}$git_branch_symbol:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[blue]%})%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}"

if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Use a different histfile per shell, and write to it immediately after each command.
TMUX_SESSION_ID=$(tmux display -pt $TMUX_PANE '#S:#I.#P')
export HISTFILE="$HOME/.zsh_sessions/history_$TMUX_SESSION_ID"
setopt INC_APPEND_HISTORY
# For new shells, initialize history with the history of the most recently used shell.
if [ ! -e $HISTFILE ]; then cp "$HOME/.zsh_sessions/$(ls -Art $HOME/.zsh_sessions | tail -n 1)" "$HISTFILE"; fi
