-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

    use('mbbill/undotree')

    -- git related
    use('tpope/vim-fugitive')
    use('airblade/vim-gitgutter')
    use('rhysd/git-messenger.vim')

    -- Language Server Protocol
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
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
    }

    use('tpope/vim-commentary')
    use('tpope/vim-surround')
    use('tpope/vim-obsession')

    -- tmux related
    use('christoomey/vim-tmux-navigator')
    use('RyanMillerC/better-vim-tmux-resizer')

    use('ciaranm/securemodelines')

    use('nvim-lualine/lualine.nvim')

    use {
        'andymass/vim-matchup',
        setup = function()
            -- may set any options here
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
        end
    }
    use('airblade/vim-rooter')
    use('mtdl9/vim-log-highlighting')
    use('jiangmiao/auto-pairs')

    use('plasticboy/vim-markdown')

    -- file tree
    use('nvim-tree/nvim-tree.lua')
    use('nvim-tree/nvim-web-devicons')

    use('HiPhish/rainbow-delimiters.nvim')

    -- plugin for popup windows
    use {'stevearc/dressing.nvim'}

    -- automatically highlighting other uses of the word under the cursor
    use { 'RRethy/vim-illuminate' }

    -- highlight arguments
    use { 'm-demare/hlargs.nvim' }

    -- color themes
    -- use { 'tanvirtin/monokai.nvim' }
    -- use { 'arcticicestudio/nord-vim' }
    use('RRethy/nvim-base16')

end)
