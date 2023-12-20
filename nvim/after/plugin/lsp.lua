local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "gy", function() vim.lsp.buf.type_definition() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "<F6>", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)

    vim.keymap.set("n", "<leader>ac", function() vim.lsp.buf.code_action() end, opts)

    vim.keymap.set("n", "<leader>l", function() vim.diagnostic.open_float() end, { silent = true })
    vim.keymap.set("n", "E", function() vim.diagnostic.goto_next() end, { silent = true })
    vim.keymap.set("n", "W", function() vim.diagnostic.goto_prev() end, { silent = true })
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
rust_tools.setup({
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', '<leader>ac', rust_tools.hover_actions.hover_actions, {buffer = bufnr})
    end
  }
})
