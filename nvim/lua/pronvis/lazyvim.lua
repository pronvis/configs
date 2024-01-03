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
        tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
    },

    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

    'mbbill/undotree',

    -- git related
    'tpope/vim-fugitive',
    'airblade/vim-gitgutter',
    'rhysd/git-messenger.vim',

    -- Language Server Protocol
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            -- managing LSP servers from neovim
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-path' },
            -- snippets
            { 'L3MON4D3/LuaSnip' },
            'saadparwaiz1/cmp_luasnip',
            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
            -- Rust
            { 'simrat39/rust-tools.nvim' },
            -- full signature help, docs and completion for the nvim lua API
            { 'folke/neodev.nvim' },
        }
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

    'plasticboy/vim-markdown',

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

    -- color themes
    -- use { 'tanvirtin/monokai.nvim' }
    -- use { 'arcticicestudio/nord-vim' }
    'RRethy/nvim-base16',

    "lukas-reineke/lsp-format.nvim",
    {
        'linrongbin16/lsp-progress.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lsp-progress').setup()
        end
    },

    'github/copilot.vim'

})
