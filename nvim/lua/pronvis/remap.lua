-- TODO: delete me
vim.api.nvim_set_keymap('n', '<leader>pv', ':Ex<CR>', {})

-- quick save
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', {})

-- ; as :
vim.api.nvim_set_keymap('n', ';', ':', { noremap = true })

-- disable useless and annoying keys
vim.api.nvim_set_keymap('', 'Q', '', { noremap = true })

-- quickly insert an empy line without entering insert mode
vim.api.nvim_set_keymap('n', '<leader>o', 'o<Esc>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>O', 'O<Esc>', { noremap = true })

-- toggle between buffers
vim.api.nvim_set_keymap('n', '<leader><leader>', '<c-^>', { noremap = true })

-- toggle between buffers
vim.api.nvim_set_keymap('n', '<leader>,', ':set invlist<cr>', { noremap = true })

-- keymap for replacing up to next _
vim.api.nvim_set_keymap('', '<leader>m', 'ct_', { noremap = true })

-- Ctrl+s to stop searching
vim.api.nvim_set_keymap('v', '<C-s>', ':nohlsearch<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-s>', ':nohlsearch<CR>', { noremap = true })

-- Suspend with Ctrl+f, wake up with 'fg' command
vim.api.nvim_set_keymap('i', '<C-f>', ':sus<CR>', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-f>', ':sus<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-f>', ':sus<CR>', { noremap = true })

-- Jump to start and end of line using home row keys
vim.api.nvim_set_keymap('', 'H', '^', {})
vim.api.nvim_set_keymap('', 'L', '$', {})

-- increment/Decrement the next number on this line
vim.api.nvim_set_keymap('n', '+', '<C-a>', { noremap = true })
vim.api.nvim_set_keymap('n', '-', '<C-x>', { noremap = true })

-- move highlighted text
vim.api.nvim_set_keymap('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true })

-- cursor stay in place when 'J'
vim.api.nvim_set_keymap('n', 'J', "mzJ`z", { noremap = true })

-- cursor at center on <C-d> / <C-u>
vim.api.nvim_set_keymap('n', '<C-d>', '<C-d>zz', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-u>', '<C-u>zz', { noremap = true })

-- search result at center
vim.api.nvim_set_keymap('n', 'n', 'nzz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'N', 'Nzz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '*', '*zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '#', '#zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'g*', 'g*zz', { noremap = true, silent = true })

-- <leader>p for paste without yanking
vim.api.nvim_set_keymap('v', '<leader>p', '\"_dp', { noremap = true })

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- <leader>s replace text on curent world
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
