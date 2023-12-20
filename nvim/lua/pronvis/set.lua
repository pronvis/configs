vim.g.mapleader = ' '

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
vim.opt.undofile = true

vim.opt.termguicolors = true

vim.opt.updatetime = 50

-- time in milliseconds to wait for a mapped sequence to complete
vim.opt.timeoutlen = 500

-- using russian language in Normal mode
vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

vim.opt.cmdheight = 2

vim.opt.signcolumn = 'yes'

-- new panel right and below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- show those damn hidden characters
-- Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
vim.opt.listchars='nbsp:¬,extends:»,precedes:«,trail:•'

-- git search in file changes
-- the same as connsole: git log -p --all -S 'search string'
-- for regular expression change to: git log -p --all -G 'match regular expression'
vim.api.nvim_create_user_command('Gsearch', 'G log -p --all -S <args>', {bang = true, nargs = '*' })
