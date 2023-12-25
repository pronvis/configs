local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
    end

    nmap('<F6>', vim.lsp.buf.rename, 'Rename')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [Definition]')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eference')
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
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {'lua_ls', 'rust_analyzer'},
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
    }
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
    sources = {
        {name = 'path'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lua'},
    },
    formatting = lsp_zero.cmp_format(),
    mapping = cmp.mapping.preset.insert({
        ['<TAB>'] = cmp.mapping.select_next_item(cmp_select),
        ['<S-TAB>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<Enter>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
})

local rust_tools = require('rust-tools')
rust_tools.setup()
