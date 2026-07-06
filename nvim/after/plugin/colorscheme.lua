-- Active colorscheme: kanagawa (wave). Alacritty's [colors] matches it.
-- (Try others live with :colorscheme kanagawa | gruvbox)
vim.cmd.colorscheme('kanagawa')

-- transparent completion-menu abbreviation background
vim.api.nvim_set_hl(0, 'CmpItemAbbr', { bg = 'NONE' })

-- Distinct diff colors (used by diffview, fugitive, native :diffthis):
-- removed lines = red, changed lines = blue, so they don't look alike.
-- Wrapped in a ColorScheme autocmd so it survives a theme switch.
local function set_diff_colors()
    vim.api.nvim_set_hl(0, 'DiffAdd',    { bg = '#2d3a2d' })                 -- added line (green)
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#3a2d2d', fg = '#f2777a' }) -- removed line (red)
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2d2d3a' })                 -- changed line (blue)
    vim.api.nvim_set_hl(0, 'DiffText',   { bg = '#46466a' })                 -- changed text within a changed line
end
set_diff_colors()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diff_colors })
