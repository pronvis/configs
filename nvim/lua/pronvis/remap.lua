-- quick save
vim.keymap.set('n', '<leader>w', vim.cmd.write, { remap = true })

-- ; as :
vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

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
-- git show hunk diff
vim.keymap.set("n", "<leader>hj", ':GitGutterPreviewHunk<CR>')

-- file tree
vim.keymap.set('n', '<F2>', (require "nvim-tree.api").tree.toggle)

-- snippets
vim.keymap.set('n', '<leader>es', function() require("luasnip.loaders").edit_snippet_files() end, { silent = true })
vim.keymap.set('i', '<A-s>', (require "luasnip").expand, { silent = true })
vim.keymap.set({ "i", "s" }, "<A-d>", function() (require "luasnip").jump(1) end, { silent = true })
vim.keymap.set({ "i", "s" }, "<A-f>", function() (require "luasnip").jump(-1) end, { silent = true })

-- very magic by defaul
vim.keymap.set('n', '?', '?\\v')
vim.keymap.set('n', '/', '/\\v')

-- exit terminal mode
vim.keymap.set('t', '<F1>', '<C-\\><C-n>')

-- to search for visually selected text
vim.keymap.set('v', '//', "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>")

vim.keymap.set('n', '<leader>i', ':lua IndentEntireFile()<CR>')

-- open new file adjacent to current file
vim.keymap.set('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>')
-- copy full file name to clipboard
vim.keymap.set('n', '<leader>P', ':let @+ = expand("%:p")<CR>')

-- do Highlighting a search term without moving the cursor https://superuser.com/questions/255023/highlighting-a-search-term-without-moving-the-cursor
vim.keymap.set('n', '*', ':let @/ = \'\\<\'.expand(\'<cword>\').\'\\>\'|set hlsearch<C-M>')

-- =============================================================================
-- This allows you to visually select a section and then hit @ to run a macro
-- on all lines. Only lines which match will change. Without this script the
-- macro would stop at lines which don’t match the macro.
-- =============================================================================
vim.keymap.set('x', '@', ':lua ExecuteMacroOverVisualRange()<CR>')
