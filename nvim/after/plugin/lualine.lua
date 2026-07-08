function ObsStatus()
    return string.format("%s", vim.fn.ObsessionStatus('Ⓡ ', 'ⓟ '))
end

-- lualine's 'auto' theme doesn't define a `terminal` mode color, so terminal
-- mode falls back to normal (both show blue). Give it a distinct color.
local theme = require('lualine.themes.auto')
theme.terminal = {
    a = { fg = '#1F1F28', bg = '#98BB6C', gui = 'bold' }, -- kanagawa springGreen
    b = theme.normal.b,
    c = theme.normal.c,
}

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = theme,
        component_separators = { left = '⌘', right = '󰴈' },
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = {
            {
                'filename',
                path = 1,
                shorting_target = 60
            }
        },
        lualine_c = { 'branch', 'diff', 'diagnostics', require('lsp-progress').progress },
        lualine_x = { ObsStatus, 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    }
}
