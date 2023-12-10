 -- top and bottom gap
vim.opt.scrolloff = 5

-- show current absolute line
vim.opt.number = true

vim.opt.relativenumber = true
vim.opt.autoindent = true 
vim.opt.encoding = 'utf-8'
vim.opt.colorcolumn = '80'
vim.opt.cursorline = false

-- nowrap
vim.wo.wrap = false
vim.wo.linebreak = true

-- enable mouse usage (all modes)
vim.opt.mouse = 'a'

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- undo history
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
