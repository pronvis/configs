local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct

require('lazy').setup({
    {
        'nvim-telescope/telescope.nvim',
        branch = 'master',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
    },

    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
    },

    'mbbill/undotree',

    -- git related
    'tpope/vim-fugitive',
    { 'lewis6991/gitsigns.nvim',                 opts = {} },
    'rhysd/git-messenger.vim',
    {
        'sindrets/diffview.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
        opts = function()
            local actions = require('diffview.actions')
            return {
                -- enhanced_diff_hl: git-style colors (deletions red in their own
                -- pane, additions green) instead of vimdiff's symmetric scheme
                -- where removed code looks green on the left.
                enhanced_diff_hl = true,
                keymaps = {
                    -- '-' already stages in the file panel; add it in the diff
                    -- panes too, so you can stage the file you're viewing.
                    view = {
                        { 'n', '-', actions.toggle_stage_entry, { desc = 'Stage / unstage the current file' } },
                    },
                },
            }
        end,
    },

    -- Claude Code IDE integration (selection/context sharing, in-editor diffs)
    {
        'coder/claudecode.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = true,
        keys = {
            { '<leader>cc', '<cmd>ClaudeCode<cr>',            desc = 'Toggle Claude Code' },
            { '<leader>cr', '<cmd>ClaudeCode --resume<cr>',   desc = 'Resume Claude Code session (picker)' },
            { '<leader>cC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue latest Claude Code session' },
            { '<leader>cf', '<cmd>ClaudeCodeFocus<cr>',       desc = 'Focus Claude Code' },
            { '<leader>cs', '<cmd>ClaudeCodeSend<cr>',        mode = 'v',                                  desc = 'Send selection to Claude' },
            { '<leader>cb', '<cmd>ClaudeCodeAdd %<cr>',       desc = 'Add current buffer/file to Claude' },
            -- accept/reject Claude's proposed diffs in-editor
            { '<leader>cy', '<cmd>ClaudeCodeDiffAccept<cr>',  desc = 'Accept Claude diff' },
            { '<leader>cn', '<cmd>ClaudeCodeDiffDeny<cr>',    desc = 'Reject Claude diff' },
        },
    },

    -- Colorschemes. Active default = kanagawa (set in colorscheme.lua).
    -- Compare live with :colorscheme kanagawa | gruvbox
    { 'rebelot/kanagawa.nvim',                   lazy = false },
    { 'ellisonleao/gruvbox.nvim',                lazy = false },

    -- which-key: popup cheatsheet of available <leader> keybindings
    { 'folke/which-key.nvim',                    event = 'VeryLazy', opts = { delay = 700 } },

    -- treesitter-context: sticky header showing current fn/scope while scrolling
    { 'nvim-treesitter/nvim-treesitter-context', opts = {} },

    -- Language Server Protocol
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- LSP Support
    'neovim/nvim-lspconfig',
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    -- snippets
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
    -- full signature help, docs and completion for the nvim lua API
    'folke/neodev.nvim',
    -- rust
    {
        'mrcjkb/rustaceanvim',
        version = '^8', -- Recommended
        lazy = false,   -- This plugin is already lazy
        ft = { 'rust' },
    },

    'tpope/vim-commentary',
    'tpope/vim-surround',
    'tpope/vim-obsession',

    -- tmux related
    'christoomey/vim-tmux-navigator',
    'RyanMillerC/better-vim-tmux-resizer',

    'ciaranm/securemodelines',

    'nvim-lualine/lualine.nvim',

    {
        'andymass/vim-matchup',
        init = function()
            -- may set any options here
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
        end
    },
    'airblade/vim-rooter',
    'mtdl9/vim-log-highlighting',
    'jiangmiao/auto-pairs',

    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        ft = { 'markdown' },
        opts = {},
    },

    -- file tree
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',

    'HiPhish/rainbow-delimiters.nvim',

    -- plugin for popup windows
    'stevearc/dressing.nvim',

    -- automatically highlighting other uses of the word under the cursor
    'RRethy/vim-illuminate',

    -- highlight arguments
    'm-demare/hlargs.nvim',

    "stevearc/conform.nvim",
    {
        'linrongbin16/lsp-progress.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lsp-progress').setup()
        end
    },

    {
        'zbirenbaum/copilot.lua',
        enabled = false
    },

    'jjshoots/betterf.nvim',

    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {}
    }
})
