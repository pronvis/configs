vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local bufnr = event.buf;

        local nmap = function(keys, func, desc)
            if desc then
                desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
        end

        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
        require("lsp-format").on_attach(client, bufnr)

        nmap('<F6>', vim.lsp.buf.rename, 'Rename')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [Definition]')
        nmap('grr',
            function() require('telescope.builtin').lsp_references({ include_declaration = false, show_line = false }) end,
            '[G]oto [R]eference')
        nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

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

local servers = {
    html = { filetypes = { 'html' } },
    -- rust_analyzer = {}, -- 'rustaceanvim' have its own rust-analyzer config
    clangd = {},
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields', 'undefined-global' } },
        },
    },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')
mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end,
}

vim.lsp.config("clang", {
    cmd = {
        "clangd",
        "--offset-encoding=utf-16",
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

require('neodev').setup()

-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
end
