vim.g.tmux_resizer_no_mappings = 1
-- horizontal
vim.g.tmux_resizer_resize_count = 5
-- vertical
vim.g.tmux_resizer_vertical_resize_count = 5

-- alt-h
vim.api.nvim_set_keymap('n', '˙', ':TmuxResizeLeft<CR>', {noremap = true, silent = true})
-- alt-j
vim.api.nvim_set_keymap('n', '∆', ':TmuxResizeDown<CR>', {noremap = true, silent = true})
-- alt-k
vim.api.nvim_set_keymap('n', '˚', ':TmuxResizeUp<CR>', {noremap = true, silent = true})
-- alt-l
vim.api.nvim_set_keymap('n', '¬', ':TmuxResizeRight<CR>', {noremap = true, silent = true})
