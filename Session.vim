let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/it/configs
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +1 nvim/lazy-lock.json
badd +14 nvim/after/plugin/lsp.lua
badd +1 nvim/after/plugin/base16.lua
badd +5 nvim/after/plugin/nvim_tree.lua
badd +1 nvim/after/plugin/telescope.lua
badd +21 nvim/lua/pronvis/autocmd.lua
badd +1 nvim/lua/pronvis/functions.lua
badd +50 nvim/lua/pronvis/lazyvim.lua
badd +44 nvim/lua/pronvis/remap.lua
badd +8 nvim/lua/pronvis/set.lua
badd +1 nvim/after/plugin/betterf.lua
badd +2 tmux/tmux.conf
badd +309 zsh/zshrc_conf.zshrc
badd +98 vim_legacy_cfg/init.vim
badd +1 nvim/lua/pronvis/init.lua
badd +1 nvim/init.lua
badd +1 nvim/snippets/rust.snippets
badd +58 README.md
badd +1 tmux-client-60936.log
badd +11 vim_legacy_cfg/coc-settings.json
badd +223 ~/.local/state/nvim/mason.log
badd +1 ~/it/configs
badd +1 nvim/after/plugin/lualine.lua
badd +1 nvim/after/plugin/undotree.lua
badd +1 nvim/after/plugin/vim-markdown.lua
badd +1 nvim/after/plugin/auto_pairs.lua
badd +41 nvim/after/plugin/copilot.lua
badd +1 nvim/after/plugin/devicons.lua
badd +1 nvim/after/plugin/hlargs.lua
badd +1 nvim/after/plugin/luasnip.lua
badd +1 nvim/scripts/closetag.vim
badd +3 nvim/scripts/rust_spacetab.vim
badd +1 scripts/ps-aux-nvim
badd +6 alacritty/alacritty.toml
badd +24 alacritty/alacritty_legacy.yml
badd +4 ~/.local/share/nvim/mason/packages/lua-language-server/libexec/meta/Lua\ 5.4\ en-us\ utf8/package.lua
badd +2 nvim/syntax/gcode.vim
badd +58 lite/tmux.conf
badd +1 lite/zshrc
badd +203 lite/nvim/init.lua
badd +15 lite/dot-push.sh
badd +58 lite/install-remote.sh
badd +2 global_gitignore
badd +2 gpg-agent.conf
badd +4 claude/settings.json
badd +111 claude/statusline-command.sh
badd +1 scripts/remind
argglobal
%argdel
$argadd ~/it/configs
edit scripts/remind
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt scripts/ps-aux-nvim
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldenable
silent! normal! zE
let &fdl = &fdl
let s:l = 1 - ((0 * winheight(0) + 23) / 46)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
