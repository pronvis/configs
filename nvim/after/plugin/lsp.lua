-- Keep LSP clients off diffview/fugitive git-blob buffers (`.git/:0:/…`) — they
-- aren't real files. marksman is handled separately (see its root_dir below): it
-- must never even *attach*, because detaching sends textDocument/didClose and
-- marksman crashes fatally trying to re-read the non-existent path. Other servers
-- tolerate the didClose, so detaching them here is fine.
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local name = vim.api.nvim_buf_get_name(event.buf)
        if name:match('^diffview://') or name:match('%.git/') or name:match('^fugitive://') then
            vim.schedule(function()
                vim.lsp.buf_detach_client(event.buf, event.data.client_id)
            end)
        end
    end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local bufnr = event.buf;

        local nmap = function(keys, func, desc)
            if desc then
                desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
        end

        nmap('<F6>', vim.lsp.buf.rename, 'Rename')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [Definition]')
        nmap('grr',
            function() require('telescope.builtin').lsp_references({ include_declaration = false, show_line = false }) end,
            '[G]oto [R]eference')
        nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ss', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace [S]ymbols')

        nmap('<leader>l', vim.diagnostic.open_float, 'Open diagnostic float window')
        nmap('E', vim.diagnostic.goto_next, 'Goto next diagnostic')
        nmap('W', vim.diagnostic.goto_prev, 'Goto prev diagnostic')
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- see `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    end,
})

require('mason').setup()
require('mason-lspconfig').setup()

local servers = { 'html', 'clangd', 'lua_ls', 'ts_ls' }

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')
mason_lspconfig.setup {
    ensure_installed = servers,
}

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--offset-encoding=utf-16",
    },
})

-- marksman crashes fatally on textDocument/didClose for diffview/fugitive
-- git-blob buffers (it re-reads the non-existent `.git/:0:/…` path). Refuse to
-- attach to those buffers at all: returning without calling on_dir means no
-- client is started, so there's no didOpen and thus no crashing didClose.
vim.lsp.config("marksman", {
    root_dir = function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match("%.git/") or name:match("^diffview://") or name:match("^fugitive://") then
            return
        end
        on_dir(vim.fs.root(bufnr, { ".marksman.toml", ".git" }) or vim.fn.getcwd())
    end,
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields', 'undefined-global' } },
        },
    }
})

vim.lsp.config("ts_ls", {
    capabilities = capabilities,
    settings = {
        typescript = {
            format = { indentSize = 2, tabSize = 2, convertTabsToSpaces = true },
        },
        javascript = {
            format = { indentSize = 2, tabSize = 2, convertTabsToSpaces = true },
        },
    },
})

vim.g.rustaceanvim = {
    server = {
        cmd = { "/usr/local/bin/rust-analyzer-mac" },
        capabilities = capabilities

    },
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
    window = {
        completion = {
            border = 'rounded',
            winhighlight = 'CursorLine:PmenuSel'
        },
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-x><C-o>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'nvim_lua' },
    },
}

-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
end
