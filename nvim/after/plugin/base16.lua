-- ==============================
-- fixing Telescope popup windows
-- ==============================
require('base16-colorscheme').with_config({
    telescope = false,
})

-- Colors
-- personal voting:
-- 1st: base16_tomorrow-night-eighties
-- 2nd: base16_gruvbox-dark-soft
-- 3rd: base16_monokai
-- 4th: base16_woodland
-- 5th: base16_3024
-- 6th: base16_ayu-dark
-- 7th: base16_blueforest
-- 8th: base16_blueish
-- 9th: base16_chalk
-- 10th: base16_catppuccin
-- vim.cmd('colorscheme base16-tomorrow-night-eighties')
-- vim.cmd('colorscheme monokai')

--------------------------------------------------------
------ FOR SOME REASON I DONT NEED THAT ANYMORE!!! -----
--------------------------------------------------------
-- -- colors is default ones, but without them telescope will not be fixed
-- require('base16-colorscheme').setup({
--     -- default
--     base00 = '#2d2d2d', -- main background (black)
--     base01 = '#393939', -- selected text in nvimtree and colorcolumn (gray)
--     base02 = '#515151', -- selected text in visual mode (gray)
--     base03 = '#999999', -- comments (gray60)
--     base04 = '#b4b7b4', -- line numbers (almost white)
--     base05 = '#cccccc', -- plain text (gray80)
--     base06 = '#00ff2c', -- ??? (gray88, almost white) (now it is lettuce green)
--     base07 = '#f300ff', -- ??? (white) (now it is super pink)
--     base08 = '#f2777a', -- root var name, for example 'vim' in 'set.lua' (rose red)
--     base09 = '#f99157', -- constant values ->false/true<-, in rust '->Some;self.<-' (orange)
--     base0A = '#ffcc66', -- in rust '->&mut<- self' (yellow)
--     base0B = '#99cc99', -- text constants (green)
--     base0C = '#66cccc', -- rust doc '->/// text<-' (cyan)
--     base0D = '#6699cc', -- '->require<-' in this file (sky blue)
--     base0E = '#cc99cc', -- keywords, in rust '->pub fn<-' (pink)
--     base0F = '#a3685a' -- '->,<-' in this file (brown)
-- })
-- ==============================
-- ==============================
-- ==============================
--
-- execute: `:so $VIMRUNTIME/syntax/hitest.vim` to find all groups currently active
-- execute `:echo copy(g:)->filter('v:key =~# "^base16"')` to find all base16 config
-- execute `:=vim.api.nvim_get_hl(0, {name = 'Pmenu'})` to get group colors

local fn = vim.fn
local cmd = vim.cmd
local set_theme_path = "$HOME/.config/tinted-theming/set_theme.lua"
local is_set_theme_file_readable = fn.filereadable(fn.expand(set_theme_path)) == 1 and true or false

if is_set_theme_file_readable then
    cmd("let base16colorspace=256")
    cmd("source " .. set_theme_path)
end

-- both are the same
-- vim.cmd[[hi CmpItemAbbr guifg=fg guibg=bg]]
vim.api.nvim_set_hl(0, 'CmpItemAbbr', { bg = "NONE" })
