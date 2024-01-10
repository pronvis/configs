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
            "node_modules", "build", "dist", "yarn.lock", ".idea", ".git", ".vscode", "package-lock.json"
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
        },
    },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>s', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
