function ObsStatus()
    return string.format("%s", vim.fn.ObsessionStatus('Ⓡ ', 'ⓟ '))
end

-- lualine's 'auto' theme doesn't define a `terminal` mode color, so terminal
-- mode falls back to normal (both show blue). Give it a distinct color.
local theme = require('lualine.themes.auto')
theme.terminal = {
    a = { fg = '#1F1F28', bg = '#98BB6C', gui = 'bold' }, -- kanagawa springGreen
    b = theme.normal.b,
    c = theme.normal.c,
}

-- In a diffview tab, lualine's `filename` renders the git-object buffer name
-- (`diffview://<gitdir>/<sha>/<path>`) shortened into unreadable noise like
-- `d:///U/p/i/k/i/b/.g/8/src/cache/mod.rs`. The path is already shown in the
-- file panel, so label diffview's own windows by the role they play instead.
--
-- Layout window symbols (diffview/scene/layouts/*): a/b are the two sides of a
-- 2-way diff; conflicting files use the 3/4-way merge layouts, where diffview's
-- own naming (see FileEntry:update_merge_context) applies.
local diffview_roles = {
    conflicting = { a = 'OURS', b = 'LOCAL', c = 'THEIRS', d = 'BASE' },
    default = { a = 'FROM', b = 'CURRENT' },
}

local diffview_panels = {
    DiffviewFiles = 'FILES',
    DiffviewFileHistory = 'HISTORY',
}

--- Role of the window this statusline is being rendered for, or nil when the
--- window is not part of a diffview layout.
--- @return string|nil
local function diffview_role()
    local panel = diffview_panels[vim.bo.filetype]
    if panel then return panel end

    local ok, lib = pcall(require, 'diffview.lib')
    if not ok then return nil end

    local view = lib.get_current_view()
    local layout = view and view.cur_layout
    if not layout then return nil end

    local curwin = vim.api.nvim_get_current_win()

    for _, sym in ipairs({ 'a', 'b', 'c', 'd' }) do
        local win = layout[sym]
        if win and win.id == curwin then
            local kind = win.file and win.file.kind
            return (diffview_roles[kind] or diffview_roles.default)[sym]
        end
    end
end

local function in_diffview_win() return diffview_role() ~= nil end
local function not_in_diffview_win() return diffview_role() == nil end

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = theme,
        component_separators = { left = '╱', right = '╱' },
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = {
            { diffview_role, cond = in_diffview_win },
            {
                'filename',
                path = 1,
                shorting_target = 60,
                cond = not_in_diffview_win,
            }
        },
        lualine_c = { 'branch', 'diff', 'diagnostics', require('lsp-progress').progress },
        lualine_x = { ObsStatus, 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            { diffview_role, cond = in_diffview_win },
            { 'filename', cond = not_in_diffview_win },
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    }
}
