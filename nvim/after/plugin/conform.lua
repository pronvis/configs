-- Formatting via conform.nvim (replaces the unmaintained lsp-format.nvim).
--
-- No external formatters are configured, so formatting is delegated to the
-- active LSP server (clangd, ts_ls, lua_ls, rust-analyzer) via `lsp_format`,
-- matching the previous behavior. To give a filetype a dedicated formatter
-- later, add it to `formatters_by_ft` (e.g. prettier, stylua, clang-format).
require("conform").setup({
    formatters_by_ft = {},

    -- Use the LSP server's formatter when no formatter is configured above.
    default_format_opts = {
        lsp_format = "fallback",
    },

    -- Format on save (previously handled by lsp-format.nvim's on_attach).
    format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
    },
})

-- Manual format command (parity with lsp-format.nvim's :Format).
vim.api.nvim_create_user_command("Format", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, {})
