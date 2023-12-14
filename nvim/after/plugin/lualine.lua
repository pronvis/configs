function ObsStatus()
    return string.format("%s", vim.fn.ObsessionStatus('Ⓡ', 'ⓟ'))
end

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'seoul256',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = {
            {
                'filename',
                path = 1,
                shorting_target = 100
            },
            'diff', 'diagnostics' },
        lualine_c = { 'branch' },
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
