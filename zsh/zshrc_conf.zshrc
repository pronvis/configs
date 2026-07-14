export LANG=en_US.UTF-8
export LC_CTYPE="$LANG"

# Alt/Option + Left/Right = jump by word.
#   mod 3 (\e[1;3D / \e[1;3C) — Alacritty's Alt+arrow, and what tmux forwards
#   mod 9 (\e[1;9D / \e[1;9C) — Kitty's Option+arrow (Meta), sent directly
#   mod 5 (\e[1;5D / \e[1;5C) — Ctrl+arrow
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;9C" forward-word
bindkey "^[[1;9D" backward-word
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

# Terminal colors come from Alacritty ([colors] = kanagawa wave).

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

# Keep PATH entries unique and only add directories that actually exist.
typeset -gU path PATH
path=()
for dir in \
	"$HOME/.dotnet/tools" \
	/usr/local/share/dotnet \
	/Applications/Alacritty.app/Contents/MacOS \
	/Applications/kitty.app/Contents/MacOS \
	/Applications/OpenSCAD.app/Contents/MacOS \
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

# Brighten a few zsh-syntax-highlighting colors that read too dark on kanagawa.
# Set after oh-my-zsh loads the plugin so these override its defaults.
# fg=10 / fg=11 are the terminal's *bright* green/yellow (kitty color10 #98BB6C,
# color11 #E6C384) — the lighter siblings of the default fg=green / fg=yellow.
if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
	# valid commands were dark green (fg=green / color2 #76946A)
	ZSH_HIGHLIGHT_STYLES[command]='fg=10'
	ZSH_HIGHLIGHT_STYLES[alias]='fg=10'
	ZSH_HIGHLIGHT_STYLES[builtin]='fg=10'
	ZSH_HIGHLIGHT_STYLES[function]='fg=10'
	ZSH_HIGHLIGHT_STYLES[precommand]='fg=10,underline'
	# quoted strings were dark gold (fg=yellow / color3 #C0A36E)
	ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=11'
	ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=11'
	ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=11'
fi

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
alias gcsm='git commit -S --message'   # GPG-sign instead of oh-my-zsh's --signoff
alias gst='git status -sb'   # GPG-sign instead of oh-my-zsh's --signoff

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
if [[ -o interactive ]] && command -v brew >/dev/null 2>&1; then
    FZF_SHELL="$(brew --prefix)/opt/fzf/shell"
    [[ -f "$FZF_SHELL/key-bindings.zsh" ]] && source "$FZF_SHELL/key-bindings.zsh"
    [[ -f "$FZF_SHELL/completion.zsh"   ]] && source "$FZF_SHELL/completion.zsh"
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
# branch name in bright red (%F{9} / #E82424); plain %{$fg[red]%} (#C34043) was too dark
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}$git_branch_symbol:(%{%F{9}%}"
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

# Put nvm's `default`-aliased Node bin on PATH at startup so global CLIs
# (openspec, openclaw, …) are found in every terminal without first invoking
# node/npm. The lazy-load above still handles `nvm use`. Resolves the `default`
# alias precisely — concrete/partial version, `node`/`stable`, or `lts/*` alias
# chains — and falls back to the highest installed version if it can't resolve
# (or resolves to a version that isn't installed).
if [ -d "$NVM_DIR/versions/node" ]; then
	__nvm_highest() { /bin/ls -d "$NVM_DIR"/versions/node/"$1"*/bin 2>/dev/null | sort -V | tail -1; }

	__nvm_tok=""
	[ -f "$NVM_DIR/alias/default" ] && __nvm_tok="$(cat "$NVM_DIR/alias/default" 2>/dev/null)"

	# Follow alias-file chains, e.g. lts/* -> lts/krypton -> v24.x (max 8 hops).
	__nvm_hops=0
	while [ -n "$__nvm_tok" ] && [ -f "$NVM_DIR/alias/$__nvm_tok" ] && [ "$__nvm_hops" -lt 8 ]; do
		__nvm_tok="$(cat "$NVM_DIR/alias/$__nvm_tok" 2>/dev/null)"
		__nvm_hops=$((__nvm_hops + 1))
	done

	case "$__nvm_tok" in
		v[0-9]*|[0-9]*) __nvm_default_bin="$(__nvm_highest "v${__nvm_tok#v}")" ;; # concrete/partial version
		*)              __nvm_default_bin="" ;;                                   # node/stable/etc -> fall through
	esac
	[ -z "$__nvm_default_bin" ] && __nvm_default_bin="$(__nvm_highest v)"         # fallback: highest installed
	[ -n "$__nvm_default_bin" ] && export PATH="$__nvm_default_bin:$PATH"

	unset -f __nvm_highest 2>/dev/null
	unset __nvm_tok __nvm_hops __nvm_default_bin
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

# Use gpg-agent as the SSH agent so the GPG authentication subkey serves SSH
# (one key for GPG signing/encryption AND SSH). gpg-agent.conf already has
# `enable-ssh-support`; this points SSH at its socket and keeps pinentry on the
# current terminal.
unset SSH_AGENT_PID
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye >/dev/null

export EDITOR="nvim"
export VISUAL="nvim"
