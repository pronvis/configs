-- Active colorscheme: kanagawa (wave). Alacritty's [colors] matches it.
-- (Try others live with :colorscheme kanagawa | gruvbox)
vim.cmd.colorscheme('kanagawa')

-- transparent completion-menu abbreviation background
vim.api.nvim_set_hl(0, 'CmpItemAbbr', { bg = 'NONE' })

-- Distinct diff colors (used by diffview, fugitive, native :diffthis).
--
-- Background tints ONLY — deliberately no `fg`. In diff mode the diff highlight
-- takes priority over syntax for whatever attributes it defines, so setting a
-- foreground here repaints every character of an added/removed line in that one
-- colour and flattens the treesitter highlighting underneath it (a whole added
-- file rendered as solid green). Leaving `fg` unset lets the language colours
-- show through, with the tint still marking what changed.
--
-- Tune the tints if the add/delete cue feels too subtle now that it's carrying
-- the signal alone. Wrapped in a ColorScheme autocmd so it survives a theme switch.
local function set_diff_colors()
    vim.api.nvim_set_hl(0, 'DiffAdd',    { bg = '#2d3a2d' }) -- added line (green tint)
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#3a2d2d' }) -- removed line (red tint)
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2d2d3a' }) -- changed line (blue tint)
    vim.api.nvim_set_hl(0, 'DiffText',   { bg = '#46466a' }) -- changed text within a changed line
    -- diff *counts* (diffview file panel's "+N, -N", git commit/diff syntax).
    -- Diffview links FilePanelInsertions->diffAdded, FilePanelDeletions->diffRemoved.
    vim.api.nvim_set_hl(0, 'diffAdded',   { fg = '#98BB6C' }) -- insertions (brightgreen)
    vim.api.nvim_set_hl(0, 'diffRemoved', { fg = '#ff5f5f' }) -- deletions (203)
end
set_diff_colors()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diff_colors })
