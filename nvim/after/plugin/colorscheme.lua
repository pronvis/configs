-- Active colorscheme: kanagawa (wave). Alacritty's [colors] matches it.
-- (Try others live with :colorscheme kanagawa | gruvbox)
vim.cmd.colorscheme('kanagawa')

-- transparent completion-menu abbreviation background
vim.api.nvim_set_hl(0, 'CmpItemAbbr', { bg = 'NONE' })

-- Distinct diff colors (used by diffview, fugitive, native :diffthis):
-- added/removed foregrounds match the terminal git colors — added = brightgreen
-- (kitty color10 #98BB6C), removed = 256-color 203 (#ff5f5f). Subtle bg tints
-- keep the add/change/delete lines distinguishable.
-- Wrapped in a ColorScheme autocmd so it survives a theme switch.
local function set_diff_colors()
    vim.api.nvim_set_hl(0, 'DiffAdd',    { bg = '#2d3a2d', fg = '#98BB6C' }) -- added line (brightgreen)
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#3a2d2d', fg = '#ff5f5f' }) -- removed line (203)
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2d2d3a' })                 -- changed line (blue)
    vim.api.nvim_set_hl(0, 'DiffText',   { bg = '#46466a' })                 -- changed text within a changed line
    -- diff *counts* (diffview file panel's "+N, -N", git commit/diff syntax).
    -- Diffview links FilePanelInsertions->diffAdded, FilePanelDeletions->diffRemoved.
    vim.api.nvim_set_hl(0, 'diffAdded',   { fg = '#98BB6C' }) -- insertions (brightgreen)
    vim.api.nvim_set_hl(0, 'diffRemoved', { fg = '#ff5f5f' }) -- deletions (203)
end
set_diff_colors()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diff_colors })
