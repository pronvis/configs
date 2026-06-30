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
    -- to move to the window above.
    pcall(vim.keymap.del, 'n', '<C-k>', { buffer = bufnr })

    -- 'i' shows node info in a float we own. nvim-tree's built-in info popup
    -- auto-closes on the next CursorMoved/BufLeave and flashes; this one only
    -- closes on a keypress (CursorMoved is deliberately NOT a close trigger).
    vim.keymap.set('n', 'i', function()
        local node = api.tree.get_node_under_cursor()
        if not node then return end
        local path = node.absolute_path or ''
        local lines = { ' ' .. path .. ' ' }
        local stat = vim.uv.fs_stat(path)
        if stat then
            local size_kb = string.format('%.1f', stat.size / 1024)
            lines[#lines + 1] = ' type: ' .. stat.type .. '   size: ' .. size_kb .. ' KB '
            lines[#lines + 1] = ' modified: ' .. os.date('%Y-%m-%d %H:%M', stat.mtime.sec) .. ' '
        end
        local width = 0
        for _, l in ipairs(lines) do width = math.max(width, #l) end
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        local win = vim.api.nvim_open_win(buf, false, {
            relative = 'cursor', row = 1, col = 0,
            width = width, height = #lines,
            style = 'minimal', border = 'rounded', focusable = false,
        })
        vim.api.nvim_create_autocmd({ 'BufLeave', 'WinClosed' }, {
            buffer = bufnr, once = true,
            callback = function() pcall(vim.api.nvim_win_close, win, true) end,
        })
        -- close on the next keypress instead of cursor movement
        local ns = vim.api.nvim_create_namespace('nvimtree_info_once')
        vim.on_key(function()
            pcall(vim.api.nvim_win_close, win, true)
            vim.on_key(nil, ns) -- unregister; let the key pass through normally
        end, ns)
    end, opts('Info'))
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
