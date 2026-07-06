-- nvim-treesitter `main` branch (Neovim 0.11+ API).
--
-- The old `require('nvim-treesitter.configs').setup{}` module system is gone.
-- Parser installation is now explicit, and highlighting is enabled per-buffer
-- via Neovim's built-in `vim.treesitter.start()` in a FileType autocmd.

local ensure_installed = {
    "java", "javascript", "typescript", "bash", "c", "lua",
    "vim", "vimdoc", "query", "rust", "toml", "cpp",
}

-- Install any missing parsers (async; a no-op when already present).
require('nvim-treesitter').install(ensure_installed)

-- Filetypes for which treesitter highlighting stays OFF.
-- markdown is handled by vim-markdown.
local highlight_disabled = {
    markdown = true,
    vimdoc = true,
}

vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if highlight_disabled[ft] then
            return
        end
        -- Only start when a parser for this filetype's language is available.
        local lang = vim.treesitter.language.get_lang(ft) or ft
        pcall(vim.treesitter.start, args.buf, lang)
    end,
})
