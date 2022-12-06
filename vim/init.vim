" =============================================================================
" # REMEMBER
" =============================================================================

" Ctrl w gives you the "windows command mode", allowing the following modifiers:
"     Ctrl w + R - To rotate windows up/left.
"     Ctrl w + r - To rotate windows down/right.

" You can also use the "windows command mode" with navigation keys to change a window's position:
"     Ctrl w + L - Move the current window to the "far right"
"     Ctrl w + H - Move the current window to the "far left"
"     Ctrl w + J - Move the current window to the "very bottom"
"     Ctrl w + K - Move the current window to the "very top"

" Check out :help window-moving for more information
" =============================================================================
" =============================================================================
" =============================================================================


let mapleader = "\<Space>"

" =============================================================================
" # PLUGINS
" =============================================================================
set nocompatible
filetype off
call plug#begin()

" Rainbow parenthesis
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', '#cc5e5e'],
\}

" VIM enhancements
Plug 'ciaranm/securemodelines'
Plug 'editorconfig/editorconfig-vim'
Plug 'justinmk/vim-sneak'

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'

" Fuzzy finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Semantic language support
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Syntastic language support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'rhysd/vim-clang-format'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" base16 support
Plug 'chriskempson/base16-vim'

" log viewer: https://github.com/MTDL9/vim-log-highlighting
Plug 'mtdl9/vim-log-highlighting'

Plug 'jiangmiao/auto-pairs'
Plug 'derekwyatt/vim-scala'
Plug 'davidpdrsn/vim-spectacular'

" syntax highlighting
Plug 'sheerun/vim-polyglot'

Plug 'christoomey/vim-tmux-navigator'
Plug 'RyanMillerC/better-vim-tmux-resizer'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-commentary'

Plug 'rhysd/git-messenger.vim'
call plug#end()

let $FZF_DEFAULT_COMMAND = "rg --files --no-ignore-vcs --hidden | rg -v \"(^|/)(target|\.git)/\" | rg -v \".DS_Store\""

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case --hidden -- '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

source ~/.config/nvim/functions.vim

" using russian language in Normal mode
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

let g:syntastic_rust_checkers = ['rustc', 'clippy']
au BufRead,BufNewFile *.conf set filetype=conf
au BufRead,BufNewFile .tmux.conf set filetype=tmux

" from https://scalameta.org/metals/docs/editors/vim.html
" Configuration for vim-scala
au BufRead,BufNewFile *.sbt set filetype=scala
autocmd FileType json syntax match Comment +\/\/.\+$+

if has('nvim')
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
    set inccommand=nosplit
    noremap <C-q> :confirm qall<CR>
end

" deal with colors
if !has('gui_running')
  set t_Co=256
endif
if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif

" Colors
" Base16
let base16colorspace=256
" personal voting:
" 1st: base16-tomorrow-night-eighties
" 2nd: base16-gruvbox-dark-soft
" 3rd: base16-monokai
" 4th: base16-woodland
if filereadable(expand("~/.vimrc_background")) 
   source ~/.vimrc_background
else
   colorscheme base16-tomorrow-night-eighties
endif

hi Normal ctermbg=NONE
" Get syntax
syntax on

" Plugin settings
let g:secure_modelines_allowed_items = [
                \ "textwidth",   "tw",
                \ "softtabstop", "sts",
                \ "tabstop",     "ts",
                \ "shiftwidth",  "sw",
                \ "expandtab",   "et",   "noexpandtab", "noet",
                \ "filetype",    "ft",
                \ "foldmethod",  "fdm",
                \ "readonly",    "ro",   "noreadonly", "noro",
                \ "rightleft",   "rl",   "norightleft", "norl",
                \ "colorcolumn"
                \ ]

" Lightline
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ 'active': {
      \   'right': [ ['lineinfo'], ['obsession_status', 'percent'], ['fileformat', 'fileencoding', 'filetype'] ],
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'cocstatus' ],
      \             [ 'git_st' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'git_st': 'GitStatus',
      \   'cocstatus': 'coc#status',
      \   'obsession_status': 'ObsStatus',
      \ },
\ }

function! ObsStatus()
	return printf('%s', ObsessionStatus("\u24c7", "\u24df"))
endfunction

function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction

let g:lightline.separator = {'left': '', 'right': ''}
let g:lightline.subseparator = {'left': '', 'right': ''}

" Javascript
let javaScript_fold=0

" Java
let java_ignore_javadoc=1

" Latex
let g:latex_indent_enabled = 1
let g:latex_fold_envs = 0
let g:latex_fold_sections = []

" SQL
let g:sql_type_default = 'pgsql'
 
" Open hotkeys
map <C-p> :Files<CR>
nmap <leader>; :Buffers<CR>

" Quick-save
nmap <leader>w :w<CR>

" racer + rust
" https://github.com/rust-lang/rust.vim/issues/192
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

let $RUST_SRC_PATH = systemlist("rustc --print sysroot")[0] . "/lib/rustlib/src/rust/src"

" Completion
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use <c-.> to trigger completion.
inoremap <silent><expr> <c-.> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" =============================================================================
" # Editor settings
" =============================================================================
" Configuration for vim-markdown
let g:vim_markdown_conceal = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_math = 1
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_autowrite = 1
let g:vim_markdown_edit_url_in = 'buffer'
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0

filetype plugin indent on
set autoindent
set timeoutlen=300 " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set encoding=utf-8
set scrolloff=5
set noshowmode
set hidden
set nowrap
set nojoinspaces
let g:sneak#s_next = 1
set printfont=:h10
set printencoding=utf-8
set printoptions=paper:letter
" Always draw sign column. Prevent buffer moving when adding/deleting sign.
set signcolumn=yes

" Sane splits
set splitright
set splitbelow

" Permanent undo
set undodir=~/.vimdid
set undofile

" Decent wildmenu
set wildmenu
set wildmode=list:longest
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor

" Use wide tabs
set shiftwidth=8
set softtabstop=8
set tabstop=8
set noexpandtab

" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" exit terminal mode
tnoremap <F1> <C-\><C-n>

" =============================================================================
" # Auto commands
" =============================================================================

augroup neorun
  autocmd!
  autocmd TermClose * :call TerminalOnTermClose(0+expand('<abuf>'))
augroup end

" =============================================================================
" # GUI settings
" =============================================================================
set guioptions-=T " Remove toolbar
set vb t_vb= " No more beeps
set backspace=2 " Backspace over newlines
set nofoldenable
set ttyfast
set nocursorline
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2
set relativenumber " Relative line numbers
set number " Also show current absolute line
set diffopt+=iwhite " No whitespace in vimdiff
" Make diffing better: https://vimways.org/2018/the-power-of-diff/
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic
set colorcolumn=80 " and give me a colored column
set showcmd " Show (partial) command in status line.
set mouse=a " Enable mouse usage (all modes) in terminals
set shortmess+=c " don't give |ins-completion-menu| messages.
" set shortmess-=S " do not show search count message when searching, e.g."[1/5]"

" Show those damn hidden characters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
set listchars=nbsp:¬,extends:»,precedes:«,trail:•

" =============================================================================
" # Keyboard shortcuts
" =============================================================================
" ; as :
nnoremap ; :

" " Reload vimr configuration file
nnoremap <Leader>vr :source $MYVIMRC<CR>

" Disable useless and annoying keys
noremap Q <Nop>

" Quickly insert an empty new line without entering insert mode
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

" git search in file changes
" the same as connsole: git log -p --all -S 'search string'
" for regular expression change to: git log -p --all -G 'match regular expression'
command! -nargs=* Gsearch :G log -p --all -S <q-args>
" git show hunk diff
nmap <leader>hj <Plug>(GitGutterPreviewHunk)
" show git message
nmap <F3> <Plug>(git-messenger)
" file explorer
nmap <F2> :CocCommand explorer<CR>

" Ctrl+h to stop searching
vnoremap <C-s> :nohlsearch<cr>
nnoremap <C-s> :nohlsearch<cr>

" Suspend with Ctrl+f
inoremap <C-f> :sus<cr>
vnoremap <C-f> :sus<cr>
nnoremap <C-f> :sus<cr>

" To search for visually selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Increment/Decrement the next number on this line
nnoremap + <C-a>
nnoremap - <C-x>

let g:tmux_resizer_no_mappings = 1

nnoremap <silent> ˙ :TmuxResizeLeft<CR>
nnoremap <silent> ∆ :TmuxResizeDown<CR>
nnoremap <silent> ˚ :TmuxResizeUp<CR>
nnoremap <silent> ¬ :TmuxResizeRight<CR>

" do Highlighting a search term without moving the cursor https://superuser.com/questions/255024/highlighting-a-search-term-without-moving-the-cursor
nnoremap * :let @/ = '\<'.expand('<cword>').'\>'\|set hlsearch<C-M>

nnoremap <leader>i :call IndentEntireFile()<cr>
"
" Run tests
nnoremap <leader>T :call RunRustTests()<cr>
nnoremap <leader>r :call RunRustCurrentTest()<cr>
nnoremap <leader>t :w<cr>:call Run_clippy_with_fix()<cr>

" Jump to start and end of line using the home row keys
map H ^
map L $

" Neat X clipboard integration
" <leader>p will paste clipboard into buffer
" <leader>c will copy entire buffer into clipboard
" noremap <leader>p :read !pbpaste<cr>
noremap <leader>c :w !pbcopy<cr><cr>

" <leader>p for paste without yanking
vnoremap <leader>p "_dp

" <leader>s for Rg search
noremap <leader>s :Rg! 

" Open new file adjacent to current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
" copy full file name to clipboard
nnoremap <leader>P :let @+ = expand("%:p")<CR>

" No arrow keys --- force yourself to use the home row
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Left and right can switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" Move by line
nnoremap j gj
nnoremap k gk

autocmd CursorHold * silent call CocActionAsync('highlight')
" TERMINAL
" see NR-8 :help cterm-colors
highlight CocHighlightText cterm=underline,bold ctermfg=white
highlight CocErrorSign ctermfg=red
highlight CocWarningSign ctermfg=yellow
highlight CocErrorHighlight ctermfg=darkred cterm=underline
" GUI
highlight CocHighlightText guifg=#c4c4c4 guibg=#4a4a4a
highlight CocErrorSign guifg=#ff3636 guibg=#393939
highlight CocWarningSign guifg=#ff922b guibg=#3a3a3a
highlight CocErrorHighlight guifg=#ff0000 
highlight MatchParen gui=none guibg=#668dff guifg=whit

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" Show commands.
nnoremap <silent> <space>C  :<C-u>CocList commands<cr>
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
" Remap keys for applying codeAction to the current line.
nmap <leader>ac v<Plug>(coc-codeaction-selected)
" 'Smart' navigation
nmap <silent> W <Plug>(coc-diagnostic-prev)
nmap <silent> E <Plug>(coc-diagnostic-next)
nmap <silent> <leader>l <Plug>(coc-diagnostic-info)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <F6> <Plug>(coc-rename)
" Use M to show signature help in preview window
nnoremap <silent> M :call CocActionAsync('showSignatureHelp')<CR>
" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! StatusDiagnostic() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let msgs = []
  if get(info, 'error', 0)
    call add(msgs, 'E' . info['error'])
  endif
  if get(info, 'warning', 0)
    call add(msgs, 'W' . info['warning'])
  endif
  return join(msgs, ' '). ' ' . get(g:, 'coc_status', '')
endfunction

" <leader><leader> toggles between buffers
nnoremap <leader><leader> <c-^>

" <leader>, shows/hides hidden characters
nnoremap <leader>, :set invlist<cr>

" <leader>q shows stats
nnoremap <leader>q g<c-g>
" Keymap for replacing up to next _ or -
noremap <leader>m ct_

" I can type :help on my own, thanks.
map <F1> <Esc>
imap <F1> <Esc>


" =============================================================================
" # Autocommands
" =============================================================================

" Prevent accidental writes to buffers that shouldn't be edited
autocmd BufRead *.orig set readonly
autocmd BufRead *.pacnew set readonly

" Leave paste mode when leaving insert mode
autocmd InsertLeave * set nopaste

" Jump to last edit position on opening file
if has("autocmd")
  " https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
  au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Follow Rust code style rules
au Filetype rust source ~/.config/nvim/scripts/spacetab.vim
au Filetype rust set colorcolumn=

au Filetype scala set colorcolumn=100

" Help filetype detection
autocmd BufRead *.plot set filetype=gnuplot
autocmd BufRead *.md set filetype=markdown
autocmd BufRead *.lds set filetype=ld
autocmd BufRead *.tex set filetype=tex
autocmd BufRead *.trm set filetype=c
autocmd BufRead *.xlsx.axlsx set filetype=ruby

" Script plugins
autocmd Filetype html,xml,xsl,php source ~/.config/nvim/scripts/closetag.vim

" =============================================================================
" This allows you to visually select a section and then hit @ to run a macro
" on all lines. Only lines which match will change. Without this script the
" macro would stop at lines which don’t match the macro.
" =============================================================================

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" =============================================================================
" Create directories before save file
" =============================================================================

function s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END


" =============================================================================
" Custom macros
" =============================================================================

func! SetDefaultValue()
" will replace `fieldName: String` with `fieldName = "FieldName",`
" first it check if current line contains `: String`
    if search('\: String', 'n', line('.')) != 0
	normal w"zywwd$A = "",hh"zp
    elseif search('\: Option\[String\]', 'n', line('.')) != 0
	normal w"zywwd$A = Some(""),hhh"zp
    endif
endfunc
let @i = ':call SetDefaultValue()'
nnoremap <leader>ri @i<cr>

" =============================================================================
" Test running
" =============================================================================
call spectacular#reset()

call spectacular#add_test_runner(
      \ 'rust, pest, toml, cfg, ron, graphql',
      \ ':call SmartRun("cargo clippy")',
      \ '.rs'
      \ )

" `find . | grep "\.rs$" | xargs touch` is workaround for
" https://github.com/rust-lang/rust-clippy/issues/4612
func! Run_clippy_with_fix()
	call spectacular#run_tests()
	execute ':!find . | grep "\.rs$" | xargs touch'
endfunc
