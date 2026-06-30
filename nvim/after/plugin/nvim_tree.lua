-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
    vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close'))

    -- free <C-k> (default: file info popup) so vim-tmux-navigator can use it
    -- to move to the window above. Keep the info popup on 'i' instead.
    pcall(vim.keymap.del, 'n', '<C-k>', { buffer = bufnr })
    vim.keymap.set('n', 'i', api.node.show_info_popup, opts('Info'))
end

require("nvim-tree").setup({
    on_attach = my_on_attach,
    update_focused_file = { enable = true },
    sort = {
        sorter = "name",
    },
    view = {
        width = 80,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = false,
    },
    actions = {
        open_file = {
            resize_window = false,
        }
    },
})
