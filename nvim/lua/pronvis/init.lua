require("pronvis.set")
require("pronvis.packer")
require("pronvis.remap")

-- Colors
-- Base16
vim.cmd('let base16colorspace=256')
-- personal voting:
-- 1st: base16-tomorrow-night-eighties
-- 2nd: base16-gruvbox-dark-soft
-- 3rd: base16-monokai
-- 4th: base16-woodland
--if filereadable(expand("~/.vimrc_background"))
--   source ~/.vimrc_background
--else
   vim.cmd('colorscheme base16-tomorrow-night-eighties')
--endif
