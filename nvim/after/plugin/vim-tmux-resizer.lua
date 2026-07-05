vim.g.tmux_resizer_no_mappings = 1
-- horizontal
vim.g.tmux_resizer_resize_count = 5
-- vertical
vim.g.tmux_resizer_vertical_resize_count = 5

-- alt-h
vim.api.nvim_set_keymap('n', '<A-h>', ':TmuxResizeLeft<CR>', { noremap = true, silent = true })
-- alt-j
vim.api.nvim_set_keymap('n', '<A-j>', ':TmuxResizeDown<CR>', { noremap = true, silent = true })
-- alt-k
vim.api.nvim_set_keymap('n', '<A-k>', ':TmuxResizeUp<CR>', { noremap = true, silent = true })
-- alt-l
vim.api.nvim_set_keymap('n', '<A-l>', ':TmuxResizeRight<CR>', { noremap = true, silent = true })

-- same resizers in terminal mode (e.g. the Claude Code terminal). alacritty.toml
-- makes Option+h/j/k/l send ESC+<letter> (i.e. <A-h/j/k/l>), so map those here.
-- <Cmd> runs the command without leaving terminal mode.
vim.api.nvim_set_keymap('t', '<A-h>', '<Cmd>TmuxResizeLeft<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-j>', '<Cmd>TmuxResizeDown<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-k>', '<Cmd>TmuxResizeUp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-l>', '<Cmd>TmuxResizeRight<CR>', { noremap = true, silent = true })
