-- Buffer-lifecycle helpers.
--
-- `close()` replaces the classic `:bp|sp|bn|bd` idiom for "delete this buffer but
-- keep my window layout". That trick split the window on purpose and relied on
-- `:bd` closing the split again — so any `:bd` failure (E89 on a modified buffer)
-- aborted the chain and left the stray split behind. Here the windows are pointed
-- at a replacement buffer first, so the layout is never touched.

local M = {}

--- Decide what to do about unsaved changes in `bufnr`.
--- @param bufnr integer
--- @return boolean proceed true if the caller may go on to delete the buffer
local function resolve_unsaved(bufnr)
    if not vim.bo[bufnr].modified then return true end

    local name = vim.api.nvim_buf_get_name(bufnr)
    name = name ~= '' and vim.fn.fnamemodify(name, ':~:.') or '[No Name]'

    local choice = vim.fn.confirm('Unsaved changes in ' .. name, '&Save\n&Discard\n&Cancel', 3)

    if choice == 1 then
        local ok, err = pcall(vim.cmd, 'write')
        if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
            return false
        end
        return true
    end

    return choice == 2 -- Discard proceeds; Cancel (or a dismissed dialog) doesn't
end

--- A buffer to show in windows currently displaying `bufnr`: the alternate
--- buffer, else any other listed buffer, else a fresh empty one — so a window
--- always has something valid to fall back to.
--- @param bufnr integer
--- @return integer
local function replacement_for(bufnr)
    local alt = vim.fn.bufnr('#')
    if alt > 0 and alt ~= bufnr and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
        return alt
    end

    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if b ~= bufnr and vim.bo[b].buflisted then return b end
    end

    return vim.api.nvim_create_buf(true, false)
end

--- Delete a buffer without disturbing the window layout.
--- @param bufnr integer|nil defaults to the current buffer
function M.close(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if not resolve_unsaved(bufnr) then return end

    local repl = replacement_for(bufnr)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
            vim.api.nvim_win_set_buf(win, repl)
        end
    end

    -- force: unsaved changes were already saved or explicitly discarded above
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

return M
