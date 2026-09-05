-- Diffview always builds a 2-way layout with the older revision on the left
-- (layout window `a`) and the newer one on the right (`b`) — see
-- Diff2Hor.create, which makes both windows with `aboveleft vsp`. There is no
-- option for the order, so exchange the two windows once they hold their
-- buffers: CURRENT (`b`) reads first, FROM (`a`) second.
--
-- Only the 2-way layouts are touched. The 3/4-way merge layouts (window `c`
-- present) carry OURS / LOCAL / THEIRS / BASE, whose order is meaningful.

--- Put layout window `b` before `a`. A no-op when they are already in that
--- order, so this can run on every diff buffer that enters a window (twice per
--- file, plus again on every entry picked in the file panel).
local function reverse_diff_windows()
    local ok, lib = pcall(require, 'diffview.lib')
    if not ok then return end

    local view = lib.get_current_view()
    local layout = view and view.cur_layout
    if not layout or layout.c then return end

    local a, b = layout.a, layout.b
    if not (a and b and a.id and b.id) then return end
    if not (vim.api.nvim_win_is_valid(a.id) and vim.api.nvim_win_is_valid(b.id)) then return end

    -- Reading order: rows first, then columns — covers both diff2_horizontal
    -- (side by side) and diff2_vertical (stacked).
    local pos_a = vim.api.nvim_win_get_position(a.id)
    local pos_b = vim.api.nvim_win_get_position(b.id)
    local a_first = pos_a[1] < pos_b[1] or (pos_a[1] == pos_b[1] and pos_a[2] < pos_b[2])
    if not a_first then return end

    -- `wincmd x` moves the windows themselves, so each window keeps its buffer
    -- and its layout symbol — the statusline labels in lualine.lua follow.
    vim.api.nvim_win_call(a.id, function() vim.cmd('wincmd x') end)
end

vim.api.nvim_create_autocmd('User', {
    pattern = 'DiffviewDiffBufWinEnter',
    group = vim.api.nvim_create_augroup('pronvis_diffview', { clear = true }),
    callback = reverse_diff_windows,
})
