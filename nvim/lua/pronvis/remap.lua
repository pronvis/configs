local map = function(mode, keys, func, desc, opt)
    if opt ~= nil and desc ~= nil then
        opt['desc'] = desc;
    elseif opt == nil and desc ~= nil then
        opt = { desc = desc }
    end
    vim.keymap.set(mode, keys, func, opt)
end

------------------------------------------------
-- ':Telescope keymaps' to search on all keymaps
------------------------------------------------

-- quick save
map('n', '<leader>w', vim.cmd.write, 'Save file', { remap = true })

-- ; as :
map('n', ';', ':')
map('v', ';', ':')

-- disable useless and annoying keys
map('', 'Q', '')

-- quickly insert an empy line without entering insert mode
map('n', '<leader>o', 'o<Esc>', 'Insert new line below')
map('n', '<leader>O', 'O<Esc>', 'Insert new line above')

map('n', '<leader><leader>', '<c-^>', 'Toggle between buffers')

map('n', '<leader>,', ':set invlist<cr>', 'Show invisible characters')

map('', '<leader>m', 'ct_', 'Replace up to next \'_\'')

map('v', '<C-s>', ':nohlsearch<CR>', 'Stop searching')
map('n', '<C-s>', ':nohlsearch<CR>', 'Stop searching')

-- Suspend with Ctrl+f, wake up with 'fg' command
map('i', '<C-f>', ':sus<CR>', 'Suspend vim')
map('v', '<C-f>', ':sus<CR>', 'Suspend vim')
map('n', '<C-f>', ':sus<CR>', 'Suspend vim')

-- Jump to start and end of line using home row keys
map('', 'H', '^', 'Jump to start of line', { remap = true })
map('', 'L', '$', 'Jump to end of line', { remap = true })

-- increment/Decrement the next number on this line
map('n', '+', '<C-a>', 'Increment next number on this line')
map('n', '-', '<C-x>', 'Decrement next number on this line')

-- move highlighted text
map('v', 'J', ":m '>+1<CR>gv=gv", 'Move highlighted text below')
map('v', 'K', ":m '<-2<CR>gv=gv", 'Move highlighted text above')

-- cursor stay in place when 'J'
map('n', 'J', "mzJ`z", 'Join with next line')

-- cursor at center on <C-d> / <C-u>
map('n', '<C-d>', '<C-d>zz', 'Jump to half of page below')
map('n', '<C-u>', '<C-u>zz', 'Jump to half of page above')

-- cursor at center on <C-o> / <C-i>
map('n', '<C-o>', '<C-o>zz', 'Jump to prev cursor location')
map('n', '<C-i>', '<C-i>zz', 'Jump to next cursor location')

-- search result at center
map('n', 'n', 'nzz', 'Jump to next search result', { silent = true })
map('n', 'N', 'Nzz', 'Jump to prev search result', { silent = true })
map('n', '#', '#zz', 'Search for current word and jump to prev', { silent = true })
map('n', 'g*', 'g*zz', 'Search for current word and jump to next', { silent = true })

-- <leader>p for paste without yanking
map('v', '<leader>p', '\"_dp', 'Paste without yanking')

-- this mapping used in `betterF` plugin
-- map("n", "<leader>f", vim.lsp.buf.format, 'Format file')

-- <leader>r replace text on curent word
map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], 'Replace text on curent word')

map("n", "<leader>;", ':Telescope buffers<CR>', 'Telesope buffers')

-- show git commit info
map("n", "<F3>", ':GitMessenger<CR>', 'Show git commit info for current line')
-- git show hunk diff
map("n", "<leader>hj", ':GitGutterPreviewHunk<CR>', 'Show git differece for current hunk')

map("n", "<leader>gp", ':GitGutterPrevHunk<CR>', 'Jump to previous git hunk')
map("n", "<leader>gn", ':GitGutterNextHunk<CR>', 'Jump to next git hunk')

-- file tree
map('n', '<F2>', (require "nvim-tree.api").tree.toggle, 'Show file tree')

-- snippets
map('n', '<leader>es', function() require("luasnip.loaders").edit_snippet_files() end, 'Edit Snippet Files',
    { silent = true })

map("n", "<leader>gg", ':so $HOME/config_repo/nvim/after/plugin/base16.lua<CR>', 'Reload color theme')

-- dont need that anymore, cause I have same behavior with <Tab>, which is configured in 'lsp.lua'
-- map('i', '<A-s>', (require "luasnip").expand, 'Expand snippet' { silent = true })
-- map({ "i", "s" }, "<A-d>", function() (require "luasnip").jump(1) end, 'Jump to next snippet edit position', { silent = true })
-- map({ "i", "s" }, "<A-f>", function() (require "luasnip").jump(-1) end, 'Jump to prev snippet edit position', { silent = true })

-- very magic by defaul
map('n', '?', '?\\v', 'Search prev')
map('n', '/', '/\\v', 'Uearch next')

-- exit terminal mode
map('t', '<F1>', '<C-\\><C-n>', 'Exit terminal mode')

-- to search for visually selected text
map('v', '//', "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", 'Search for visually selected text')

map('n', '<leader>i', ':lua IndentEntireFile()<CR>', 'Indent entire file')

-- open new file adjacent to current file
map('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>', 'Open new file adjacent to current file')
-- copy full file name to clipboard
map('n', '<leader>P', ':let @+ = expand("%:p")<CR>', 'Copy full file name to clipboard')

-- do Highlighting a search term without moving the cursor https://superuser.com/questions/255023/highlighting-a-search-term-without-moving-the-cursor
map('n', '*', ':let @/ = \'\\<\'.expand(\'<cword>\').\'\\>\'|set hlsearch<C-M>', 'Search for current word')

-- =============================================================================
-- This allows you to visually select a section and then hit @ to run a macro
-- on all lines. Only lines which match will change. Without this script the
-- macro would stop at lines which don’t match the macro.
-- =============================================================================
map('x', '@', ':lua ExecuteMacroOverVisualRange()<CR>',
    'Visually select a section and then hit @ to run a macro on all lines')

-- =========================
--   command line mappings
-- =========================

map('c', '<C-a>', '<C-b>', 'Back to the beginning of the line')
map('c', '<A-Left>', '<C-Left>', 'Move back a word')
map('c', '<A-Right>', '<C-Right>', 'Move forward a word')
map('c', '<A-BS>', '<C-w>', 'Remove one word before the cursor')

-- very magic by defaul
map('c', '%s/', '%sm/')

-- keymaps for betterF plugin
-- change to:
-- `map({ 'n', 'o' }, 'f', [[:lua betterF(true)<CR>]], { noremap = true, silent = true })`
-- and it will work for `cf` & `cF` too.
map('n', 'f', [[:lua betterF(true)<CR>]], { noremap = true, silent = true })
map('n', 'F', [[:lua betterF(false)<CR>]], { noremap = true, silent = true })
-- =========================
-- =========================
-- =========================
