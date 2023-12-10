vim.g.mapleader = ' '

-- TODO: delete me
vim.api.nvim_set_keymap('n', '<leader>pv', ':Ex<CR>', {})

-- quick save
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', {})

-- ; as :
vim.api.nvim_set_keymap('n', ';', ':', {noremap = true})

-- disable useless and annoying keys
vim.api.nvim_set_keymap('', 'Q', '', {noremap = true})

-- quickly insert an empy line without entering insert mode
vim.api.nvim_set_keymap('n', '<leader>o', 'o<Esc>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>O', 'O<Esc>', {noremap = true})

-- toggle between buffers
vim.api.nvim_set_keymap('n', '<leader><leader>', '<c-^>', { noremap = true } )

-- toggle between buffers
vim.api.nvim_set_keymap('n', '<leader>,', ':set invlist<cr>', { noremap = true } )

-- keymap for replacing up to next _
vim.api.nvim_set_keymap('', '<leader>m', 'ct_', { noremap = true } )

-- Ctrl+s to stop searching
vim.api.nvim_set_keymap('v', '<C-s>', ':nohlsearch<CR>', { noremap = true } )
vim.api.nvim_set_keymap('n', '<C-s>', ':nohlsearch<CR>', { noremap = true } )

-- Suspend with Ctrl+f, wake up with 'fg' command
vim.api.nvim_set_keymap('i', '<C-f>', ':sus<CR>', { noremap = true } )
vim.api.nvim_set_keymap('v', '<C-f>', ':sus<CR>', { noremap = true } )
vim.api.nvim_set_keymap('n', '<C-f>', ':sus<CR>', { noremap = true } )

-- Jump to start and end of line using home row keys
vim.api.nvim_set_keymap('', 'H', '^', {})
vim.api.nvim_set_keymap('', 'L', '$', {})

-- increment/Decrement the next number on this line
vim.api.nvim_set_keymap('n', '+', '<C-a>', { noremap = true } )
vim.api.nvim_set_keymap('n', '-', '<C-x>', { noremap = true } )
