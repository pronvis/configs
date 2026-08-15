-- :ReloadLsp — re-attach language tooling without restarting nvim.
--
-- Symptom this exists for: after a branch switch a file sometimes renders with
-- no colour at all and no LSP features. Two separate things detach there:
--
--   * the LSP client (rust-analyzer may exit when the workspace changes under it)
--   * the treesitter highlighter — which is what actually paints the buffer,
--     since `@lsp.*` semantic groups are blanked in after/plugin/lsp.lua
--
-- Both are (re)started from the FileType event, so the fix is: stop the clients,
-- drop the highlighter, then re-fire FileType and let the normal attach path run
-- exactly as it does on a fresh nvim.
--
-- Buffer contents are never reloaded, so this is safe with unsaved changes.
--
--   :ReloadLsp        every loaded buffer (closest to an nvim restart)
--   :ReloadLsp buf    just the current buffer (skips re-indexing the workspace)

local M = {}

local STOP_TIMEOUT_MS = 3000

--- Loaded, real buffers worth re-attaching (skips scratch/terminal/plugin UIs).
--- @return integer[]
local function reloadable_buffers()
    return vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf)
            and vim.bo[buf].buftype == ''
            and vim.bo[buf].filetype ~= ''
    end, vim.api.nvim_list_bufs())
end

--- Stop the given clients and wait for them to actually exit, so the re-attach
--- starts a fresh server instead of reusing the dying one.
--- @param clients vim.lsp.Client[]
--- @return boolean exited false if some client outlived the timeout
local function stop_clients(clients)
    if #clients == 0 then return true end

    local ids = {}
    for _, client in ipairs(clients) do
        ids[#ids + 1] = client.id
        vim.lsp.stop_client(client.id, true) -- force: don't wait for a polite shutdown
    end

    return vim.wait(STOP_TIMEOUT_MS, function()
        for _, id in ipairs(ids) do
            if vim.lsp.get_client_by_id(id) then return false end
        end
        return true
    end, 50)
end

--- Re-run the FileType event for a buffer: restarts treesitter highlighting and
--- lets every FileType-driven LSP attach (lspconfig, rustaceanvim) run again.
---
--- Re-assigning 'filetype' is used rather than `:doautocmd FileType` on purpose:
--- `:doautocmd` also processes modelines unless <nomodeline> is passed, which can
--- silently change 'syntax'/'filetype' from text inside the file. Setting the
--- option fires FileType for exactly this buffer with no modeline side effects.
--- @param buf integer
local function reattach(buf)
    pcall(vim.treesitter.stop, buf)

    -- Drop any stale vim-regex syntax as well: with treesitter driving the
    -- colours, a half-loaded syntax file left behind can repaint the buffer via
    -- its Error groups.
    vim.bo[buf].syntax = 'OFF'

    local ft = vim.bo[buf].filetype
    vim.bo[buf].filetype = ft
end

--- @param scope string|nil "buf" for the current buffer, anything else = all
function M.reload(scope)
    local bufs = scope == 'buf' and { vim.api.nvim_get_current_buf() } or reloadable_buffers()

    local clients = {}
    for _, buf in ipairs(bufs) do
        vim.list_extend(clients, vim.lsp.get_clients({ bufnr = buf }))
    end

    local stopped = stop_clients(clients)
    if not stopped then
        vim.notify('ReloadLsp: some clients did not exit in time; re-attaching anyway',
            vim.log.levels.WARN)
    end

    for _, buf in ipairs(bufs) do
        reattach(buf)
    end

    -- Servers attach asynchronously; report once they have had a moment to come up.
    vim.defer_fn(function()
        local names = {}
        for _, client in ipairs(vim.lsp.get_clients()) do
            names[#names + 1] = client.name
        end
        table.sort(names)
        vim.notify(('ReloadLsp: %d buffer(s) re-attached — %s')
            :format(#bufs, #names > 0 and table.concat(names, ', ') or 'no LSP clients'),
            vim.log.levels.INFO)
    end, 1500)
end

--- :HlAt — what is actually painting the character under the cursor?
---
--- Answers "why is this text the wrong colour". Reports every layer in priority
--- order (semantic tokens > treesitter > vim syntax) with the resolved colour, so
--- a buffer that renders all-one-colour immediately shows which layer is doing it.
local function highlight_at_cursor()
    local buf = vim.api.nvim_get_current_buf()
    local pos = vim.api.nvim_win_get_cursor(0)
    local info = vim.inspect_pos(buf, pos[1] - 1, pos[2])

    local function fg_of(group)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if not ok then return '?' end
        if next(hl) == nil then return 'BLANK (renders as default fg)' end
        return hl.fg and ('#%06x'):format(hl.fg) or 'no fg'
    end

    local lines = {
        ('buffer %d  %s'):format(buf, vim.fn.expand('%:.')),
        ("filetype=%s  syntax=%s  treesitter=%s"):format(
            vim.bo[buf].filetype,
            vim.bo[buf].syntax == '' and '(none)' or vim.bo[buf].syntax,
            tostring(vim.treesitter.highlighter.active[buf] ~= nil)),
        ('word under cursor: %s'):format(vim.fn.expand('<cword>')),
        '',
    }

    local function section(title, items, name_of)
        lines[#lines + 1] = title .. ':'
        if not items or #items == 0 then
            lines[#lines + 1] = '   (none)'
            return
        end
        for _, item in ipairs(items) do
            local g = name_of(item)
            lines[#lines + 1] = ('   %-45s %s'):format(g, fg_of(g))
        end
    end

    section('semantic tokens (highest priority)', info.semantic_tokens,
        function(t) return (t.opts and t.opts.hl_group) or '?' end)
    section('treesitter', info.treesitter, function(t) return t.hl_group end)
    section('vim syntax', info.syntax, function(t) return t.hl_group end)

    local clients = {}
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do clients[#clients + 1] = c.name end
    lines[#lines + 1] = ''
    lines[#lines + 1] = 'lsp clients: ' .. (#clients > 0 and table.concat(clients, ', ') or 'NONE')

    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

function M.setup()
    vim.api.nvim_create_user_command('ReloadLsp', function(o)
        M.reload(o.args ~= '' and o.args or nil)
    end, {
        nargs = '?',
        complete = function() return { 'buf' } end,
        desc = 'Restart LSP + treesitter attach (arg "buf" = current buffer only)',
    })

    vim.api.nvim_create_user_command('HlAt', highlight_at_cursor, {
        desc = 'Show which highlight layer is colouring the character under the cursor',
    })
end

return M
