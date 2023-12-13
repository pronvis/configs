-- TODO: delete me
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { remap = true })

-- quick save
vim.keymap.set('n', '<leader>w', vim.cmd.write, { remap = true })

-- ; as :
vim.keymap.set('n', ';', ':')

-- disable useless and annoying keys
vim.keymap.set('', 'Q', '')

-- quickly insert an empy line without entering insert mode
vim.keymap.set('n', '<leader>o', 'o<Esc>')
vim.keymap.set('n', '<leader>O', 'O<Esc>')

-- toggle between buffers
vim.keymap.set('n', '<leader><leader>', '<c-^>')

-- toggle between buffers
vim.keymap.set('n', '<leader>,', ':set invlist<cr>')

-- keymap for replacing up to next _
vim.keymap.set('', '<leader>m', 'ct_')

-- Ctrl+s to stop searching
vim.keymap.set('v', '<C-s>', ':nohlsearch<CR>')
vim.keymap.set('n', '<C-s>', ':nohlsearch<CR>')

-- Suspend with Ctrl+f, wake up with 'fg' command
vim.keymap.set('i', '<C-f>', ':sus<CR>')
vim.keymap.set('v', '<C-f>', ':sus<CR>')
vim.keymap.set('n', '<C-f>', ':sus<CR>')

-- Jump to start and end of line using home row keys
vim.keymap.set('', 'H', '^', { remap = true })
vim.keymap.set('', 'L', '$', { remap = true })

-- increment/Decrement the next number on this line
vim.keymap.set('n', '+', '<C-a>')
vim.keymap.set('n', '-', '<C-x>')

-- move highlighted text
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- cursor stay in place when 'J'
vim.keymap.set('n', 'J', "mzJ`z")

-- cursor at center on <C-d> / <C-u>
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- search result at center
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })
vim.keymap.set('n', '*', '*zz', { silent = true })
vim.keymap.set('n', '#', '#zz', { silent = true })
vim.keymap.set('n', 'g*', 'g*zz', { silent = true })

-- <leader>p for paste without yanking
vim.keymap.set('v', '<leader>p', '\"_dp')

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- <leader>s replace text on curent world
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>;", ':Telescope buffers<CR>')

-- show git commit info
vim.keymap.set("n", "<F3>", ':GitMessenger<CR>')
