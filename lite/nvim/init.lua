-- Lightweight neovim init for remote servers.
--
-- Differences vs the full local config:
--   - No LSP (mason / lspconfig / nvim-cmp / mason-lspconfig)
--   - No treesitter (avoids C compilation on first install)
--   - No copilot, rustaceanvim, luasnip, friendly-snippets, lualine
--   - No nvim-tree (netrw is builtin and good enough for ad-hoc edits)
--   - Only essential plugins: telescope, fugitive, gitgutter, git-messenger,
--     commentary, surround, vim-tmux-navigator
--
-- All muscle-memory keymaps from remap.lua are preserved where the
-- underlying plugin/feature is still available. References to luasnip /
-- nvim-tree are dropped or rerouted to builtins.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--------------------------------------------------------------------------
-- options (cherry-picked from set.lua)
--------------------------------------------------------------------------
local opt = vim.opt

opt.scrolloff       = 5
opt.number          = true
opt.relativenumber  = true
opt.autoindent      = true
opt.encoding        = 'utf-8'
opt.colorcolumn     = '120'
opt.textwidth       = 120
opt.cursorline      = false
opt.wrap            = false
opt.linebreak       = true
opt.mouse           = 'a'

opt.tabstop         = 4
opt.softtabstop     = 4
opt.shiftwidth      = 4
opt.expandtab       = true

opt.undodir         = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile        = true

opt.termguicolors   = true
opt.updatetime      = 50
opt.timeoutlen      = 500

opt.langmap =
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

opt.cmdheight    = 2
opt.signcolumn   = 'yes'
opt.ignorecase   = true
opt.splitright   = true
opt.splitbelow   = true
opt.listchars    = 'nbsp:¬,extends:»,precedes:«,trail:•'

--------------------------------------------------------------------------
-- autocmds (cherry-picked; dropped the lsp/lualine one)
--------------------------------------------------------------------------
local au = vim.api.nvim_create_autocmd
local grp = function(n) return vim.api.nvim_create_augroup(n, { clear = true }) end

au("BufRead", {
    pattern = { "*.orig", "*.pacnew" },
    group   = grp("readonly_group"),
    callback = function() vim.opt.readonly = true end,
})

au("BufWritePre", {
    pattern = "*",
    group   = grp("create_dir"),
    callback = function() vim.cmd(':write ++p') end,
})

au("TextYankPost", {
    pattern = "*",
    group   = grp("highlight_yank"),
    callback = function()
        vim.highlight.on_yank { silent = true, higroup = 'IncSearch', timeout = 300 }
    end,
})

--------------------------------------------------------------------------
-- plugin manager (lazy.nvim auto-bootstrap)
--------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- fuzzy finder (used by <leader>; for buffer switching)
    {
        'nvim-telescope/telescope.nvim',
        branch       = 'master',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },

    -- git
    'tpope/vim-fugitive',
    'airblade/vim-gitgutter',
    'rhysd/git-messenger.vim',

    -- text manipulation
    'tpope/vim-commentary',
    'tpope/vim-surround',

    -- seamless C-h/j/k/l between vim splits and tmux panes
    'christoomey/vim-tmux-navigator',
})

--------------------------------------------------------------------------
-- keymaps (cherry-picked from remap.lua; luasnip/nvim-tree refs removed)
--------------------------------------------------------------------------
local function map(mode, keys, func, desc, o)
    o = o or {}
    if desc then o.desc = desc end
    vim.keymap.set(mode, keys, func, o)
end

map('n', '<leader>w', vim.cmd.write, 'Save file', { remap = true })
map('n', ';', ':')
map('v', ';', ':')
map('',  'Q', '')

map('n', '<leader>o', 'o<Esc>', 'Insert new line below')
map('n', '<leader>O', 'O<Esc>', 'Insert new line above')

map('n', '<leader><leader>', '<c-^>', 'Toggle between buffers')
map('n', '<leader>,', ':set invlist<cr>', 'Show invisible characters')
map('',  '<leader>m', 'ct_', "Replace up to next '_'")
map('v', '<C-s>', ':nohlsearch<CR>', 'Stop searching')
map('n', '<C-s>', ':nohlsearch<CR>', 'Stop searching')

map('i', '<C-f>', ':sus<CR>', 'Suspend vim')
map('v', '<C-f>', ':sus<CR>', 'Suspend vim')
map('n', '<C-f>', ':sus<CR>', 'Suspend vim')

map('', 'H', '^', 'Jump to start of line', { remap = true })
map('', 'L', '$', 'Jump to end of line',   { remap = true })

map('n', '+', '<C-a>', 'Increment next number on this line')
map('n', '-', '<C-x>', 'Decrement next number on this line')

map('v', 'J', ":m '>+1<CR>gv=gv", 'Move highlighted text below')
map('v', 'K', ":m '<-2<CR>gv=gv", 'Move highlighted text above')

map('n', 'J', 'mzJ`z', 'Join with next line')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', '<C-o>', '<C-o>zz')
map('n', '<C-i>', '<C-i>zz')

map('n', 'n', 'nzz', nil, { silent = true })
map('n', 'N', 'Nzz', nil, { silent = true })
map('n', '#', '#zz', nil, { silent = true })
map('n', 'g*', 'g*zz', nil, { silent = true })

map('v', '<leader>p', '"_dp', 'Paste without yanking')
map('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>')
map('n', '<leader>r',
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    'Replace text on current word')

map('n', '<leader>;',
    function() require('telescope.builtin').buffers({ sort_mru = true, ignore_current_buffer = true }) end,
    'Telescope buffers')

map('n', '<F3>',         ':GitMessenger<CR>',        'Show git commit info for current line')
map('n', '<leader>hj',   ':GitGutterPreviewHunk<CR>', 'Show git diff for current hunk')
map('n', '<leader>gp',   ':GitGutterPrevHunk<CR>',    'Jump to previous git hunk')
map('n', '<leader>gn',   ':GitGutterNextHunk<CR>',    'Jump to next git hunk')

-- F2 → netrw file explorer (replaces nvim-tree in the full config)
map('n', '<F2>', ':Lexplore<CR>', 'Toggle netrw side panel')

map('n', '?', '?\\v')
map('n', '/', '/\\v')

map('t', '<F1>', '<C-\\><C-n>', 'Exit terminal mode')
map('v', '//',   "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", 'Search for visually selected text')

map('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>',
    'Open new file adjacent to current file')
map('n', '<leader>P', ':let @+ = expand("%:p")<CR>',
    'Copy full file name to clipboard')

map('n', '*',
    ':let @/ = \'\\<\'.expand(\'<cword>\').\'\\>\'|set hlsearch<C-M>',
    'Search for current word')

-- command-line bindings
map('c', '<C-a>',      '<C-b>',     'Back to the beginning of the line')
map('c', '<A-Left>',   '<C-Left>',  'Move back a word')
map('c', '<A-Right>',  '<C-Right>', 'Move forward a word')
map('c', '<A-BS>',     '<C-w>',     'Remove one word before the cursor')
map('c', '%s/',        '%sm/',      'Very magic substitute')
