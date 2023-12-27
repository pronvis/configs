-- ==============================
-- fixing Telescope popup windows
-- ==============================
require('base16-colorscheme').with_config({
    telescope = false,
})
-- colors is default ones, but without them telescope will not be fixed
require('base16-colorscheme').setup({
    -- default
    base00 = '#2d2d2d', -- main background (black)
    base01 = '#393939', -- selected text in nvimtree and colorcolumn (gray)
    base02 = '#515151', -- selected text in visual mode (gray)
    base03 = '#999999', -- comments (gray60)
    base04 = '#b4b7b4', -- line numbers (almost white)
    base05 = '#cccccc', -- plain text (gray80)
    base06 = '#00ff2c', -- ??? (gray88, almost white) (now it is lettuce green)
    base07 = '#f300ff', -- ??? (white) (now it is super pink)
    base08 = '#f2777a', -- root var name, for example 'vim' in 'set.lua' (rose red)
    base09 = '#f99157', -- constant values ->false/true<-, in rust '->Some;self.<-' (orange)
    base0A = '#ffcc66', -- in rust '->&mut<- self' (yellow)
    base0B = '#99cc99', -- text constants (green)
    base0C = '#66cccc', -- rust doc '->/// text<-' (cyan)
    base0D = '#6699cc', -- '->require<-' in this file (sky blue)
    base0E = '#cc99cc', -- keywords, in rust '->pub fn<-' (pink)
    base0F = '#a3685a' -- '->,<-' in this file (brown)
})
-- ==============================
-- ==============================
-- ==============================
-- execute: `:so $VIMRUNTIME/syntax/hitest.vim` to find all groups currently active
