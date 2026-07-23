local fb_actions = require('telescope._extensions.file_browser.actions')
local ts_builtin = require('telescope.builtin')
local ts_actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
        },

        file_ignore_patterns = {
            "^build/", "^dist/", "yarn.lock", "^.idea/", "^.git/", "^.vscode/", "package-lock.json"
        },
    },

    pickers = {
        find_files = {
            -- needed to exclude some files & dirs from general search
            -- when not included or specified in .gitignore
            find_command = {
                "rg",
                "--files",
                "--hidden",
            },
        }
    },

    extensions = {
        file_browser = {
            hidden = true,        -- show dotfiles
            grouped = true,       -- folders first
            hijack_netrw = false, -- keep nvim-tree as the file tree
            mappings = {
                ['i'] = {
                    ['<Left>'] = fb_actions.goto_parent_dir, -- up a directory
                    ['<Right>'] = ts_actions.select_default, -- into dir / open file
                },
            },
        },
    },
}
require('telescope').load_extension('file_browser')

vim.keymap.set('n', '<leader>S', function()
    ts_builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = 'Grep string' })

-- <C-p>: fuzzy find files across the project (from root). Inside, <C-f> drops
-- into the file browser at the current file's dir (navigate/create), carrying
-- the typed text. The browser's own <C-f> jumps back — so <C-f> toggles modes.
vim.keymap.set('n', '<C-p>', function()
    ts_builtin.find_files({
        attach_mappings = function(_, map)
            map('i', '<C-p>', function(prompt_bufnr)
                local line = require('telescope.actions.state').get_current_line()
                ts_actions.close(prompt_bufnr)
                require('telescope').extensions.file_browser.file_browser({
                    path = vim.fn.expand('%:p:h'),
                    select_buffer = true,
                    default_text = line,
                })
            end)
            return true
        end,
    })
end, { desc = 'Find files (project)' })
