-- Drop the treesitter provider: nvim-treesitter's locals.lua occasionally
-- returns a nil node and vim-illuminate calls :parent() on it.
require('illuminate').configure {
    providers = { 'lsp', 'regex' },
}
