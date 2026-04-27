export LANG=en_US.UTF-8
export LC_CTYPE="$LANG"

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

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

# ================================================================ 
# ================================================================ 
# ================================================================ 
# Codex suggested this, but for some reason I have `command not found: base16_tomorrow-night-eighties` on `omz update`.
# Ask Codex again at 29 april
###### if [[ -o interactive && -s "$BASE16_SHELL_PATH/profile_helper.sh" ]]; then
###### 	source "$BASE16_SHELL_PATH/profile_helper.sh"
###### 	command -v base16_tomorrow-night-eighties >/dev/null 2>&1 && base16_tomorrow-night-eighties
###### fi
# ================================================================ 
# ================================================================ 
# ================================================================ 

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
export CARGO_TARGET_DIR="$HOME/rust/rust_build_artifacts"
export GOPATH="$HOME/go"
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# you need to install https://vulkan.lunarg.com/sdk/home first
export VULKAN_SDK=$HOME/vulkan_sdk/macOS
export DYLD_LIBRARY_PATH=$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH
export VK_ICD_FILENAMES=$VULKAN_SDK/etc/vulkan/icd.d/MoltenVK_icd.json
export VK_LAYER_PATH=$VULKAN_SDK/etc/vulkan/explicit_layer.d

# Keep PATH entries unique and only add directories that actually exist.
typeset -gU path PATH
path=()
for dir in \
	"$HOME/.dotnet/tools" \
	/usr/local/share/dotnet \
	/Applications/Alacritty.app/Contents/MacOS \
	/Applications/OpenSCAD.app/Contents/MacOS \
	"$VULKAN_SDK/bin" \
	"$GOPATH/bin" \
	"$HOME/.cargo/bin" \
	"$HOME/bin/scripts" \
	"$HOME/.local/bin" \
	"$HOME/bin" \
	/usr/local/opt/llvm/bin \
	/usr/local/opt/nss/bin \
	/opt/local/bin \
	/opt/homebrew/bin \
	/opt/homebrew/sbin \
	/usr/local/bin \
	/usr/bin \
	/bin \
	/usr/sbin \
	/sbin \
	/Library/Apple/usr/bin
do
	[[ -d "$dir" ]] && path+=("$dir")
done

source "$ZSH/oh-my-zsh.sh"

fpath+=("$HOME/.zsh_functions")

# For autojump
if [[ -o interactive ]] && command -v brew >/dev/null 2>&1; then
	BREW_PREFIX="$(brew --prefix 2>/dev/null)"
	[[ -n "$BREW_PREFIX" && -s "$BREW_PREFIX/etc/autojump.sh" ]] && source "$BREW_PREFIX/etc/autojump.sh"
fi

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
 if [[ -f "$1" ]]; then
 case "$1" in
 *.tar.bz2)   tar xjf "$1"      ;;
 *.tar.gz)    tar xzf "$1"      ;;
 *.bz2)       bunzip2 "$1"      ;;
 *.rar)       unrar x "$1"      ;;
 *.gz)        gunzip "$1"       ;;
 *.tar)       tar xf "$1"       ;;
 *.tbz2)      tar xjf "$1"      ;;
 *.tbz)       tar -xjvf "$1"    ;;
 *.tgz)       tar xzf "$1"      ;;
 *.zip)       unzip "$1"        ;;
 *.Z)         uncompress "$1"   ;;
 *.7z)        7z x "$1"         ;;
 *)           echo "I don't know how to extract '$1'..." ;;
 esac
 else
 echo "'$1' is not a valid file"
 fi
}

pk () {
 if [[ -n "$1" && -n "$2" ]]; then
 if [[ ! -e "$2" ]]; then
 echo "'$2' does not exist"
 return 1
 fi
 case "$1" in
 tbz)       tar cjvf "$2.tar.bz2" "$2"       ;;
 tgz)       tar czvf "$2.tar.gz" "$2"        ;;
 tar)       tar cpvf "$2.tar" "$2"           ;;
 bz2)       if [[ -d "$2" ]]; then
             tar cjvf "$2.tar.bz2" "$2"
            else
             bzip2 -c -9 -- "$2" > "$2.bz2"
            fi ;;
 gz)        if [[ -d "$2" ]]; then
             tar czvf "$2.tar.gz" "$2"
            else
             gzip -c -9 -n -- "$2" > "$2.gz"
            fi ;;
 zip)       zip -r "$2.zip" "$2"             ;;
 7z)        7z a "$2.7z" "$2"                ;;
 *)         echo "'$1' cannot be packed via pk()" ;;
 esac
 else
 echo "Usage: pk <tbz|tgz|tar|bz2|gz|zip|7z> <path>"
 fi
}

local ret_status="%(?:%{$fg_bold[green]%}%~ ➜ :%{$fg_bold[red]%}%~ ➜ )"
PROMPT='${ret_status}%{$reset_color%}$(git_prompt_info)'

# Don't share history across tabs
# https://superuser.com/questions/1245273/iterm2-version-3-individual-history-per-tab
unsetopt share_history

export FZF_DEFAULT_COMMAND='rg --hidden --files'

if [[ -o interactive && -f "$HOME/.fzf.zsh" ]]; then
	source "$HOME/.fzf.zsh"
fi

if [[ -o interactive && -e "${HOME}/.iterm2_shell_integration.zsh" ]]; then
	source "${HOME}/.iterm2_shell_integration.zsh"
fi

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

# Lazy loading
export NVM_DIR="$HOME/.nvm"
load_nvm() {
	unset -f nvm node npm npx pnpm yarn corepack
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}

if [[ -o interactive && -s "$NVM_DIR/nvm.sh" ]]; then
	for cmd in nvm node npm npx pnpm yarn corepack; do
		eval "$cmd() { load_nvm; $cmd \"\$@\"; }"
	done
fi

# Use a different histfile per shell, and write to it immediately after each command.
mkdir -p "$HOME/.zsh_sessions"
TMUX_SESSION_ID=""
if [[ -n "$TMUX" && -n "$TMUX_PANE" ]] && command -v tmux >/dev/null 2>&1; then
	TMUX_SESSION_UID="$(tmux display-message -p -t "$TMUX_PANE" '#{session_id}_#{window_id}_#{pane_id}' 2>/dev/null)"
	if [[ "$TMUX_SESSION_UID" == \$<->_@<->_%<-> ]]; then
		TMUX_SESSION_ID="$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)"
	fi
fi
if [[ -z "$TMUX_SESSION_ID" && -n "$TMUX_PANE" ]]; then
	TMUX_SESSION_ID="pane_${TMUX_PANE#%}"
fi
if [[ -z "$TMUX_SESSION_ID" ]]; then
	TMUX_SESSION_ID="${HOST%%.*}:$$"
fi
TMUX_SESSION_ID="${TMUX_SESSION_ID//$'\n'/_}"
TMUX_SESSION_ID="${TMUX_SESSION_ID//$'\r'/_}"
TMUX_SESSION_ID="${TMUX_SESSION_ID//\//_}"
TMUX_SESSION_ID="${TMUX_SESSION_ID//[^A-Za-z0-9 .:_-]/_}"
export HISTFILE="$HOME/.zsh_sessions/history_$TMUX_SESSION_ID"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY INC_APPEND_HISTORY
if [[ -z "${ZSH_HISTORY_SESSION_INITIALIZED:-}" ]]; then
	export ZSH_HISTORY_SESSION_INITIALIZED=1
	fc -p "$HISTFILE" "$HISTSIZE" "$SAVEHIST"
	if [[ -r "$HISTFILE" ]]; then
		fc -R "$HISTFILE"
	else
		latest_history="$(ls -Art "$HOME/.zsh_sessions" 2>/dev/null | tail -n 1)"
		if [[ -n "$latest_history" ]]; then
			fc -R "$HOME/.zsh_sessions/$latest_history"
		else
			: > "$HISTFILE"
		fi
	fi
fi


# from 'man gpg-agent'
GPG_TTY=$(tty)
export GPG_TTY
