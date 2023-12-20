-- prevent accidental writes to buffers that shouldn't be edited
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = {"*.orig", "*.pacnew"},
    callback = function()
        vim.opt.readonly = true
    end
})

-- follow Rust code style rules
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = "rust",
    callback = function()
        vim.cmd(':source ~/.config/nvim/scripts/rust_spacetab.vim')
        vim.opt.colorcolumn=''
    end
})

-- help filetype detection
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = "*.plot",
    callback = function()
        vim.opt.filetype = 'gnuplot'
    end
})
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = "*.md",
    callback = function()
        vim.opt.filetype = 'markdown'
    end
})

-- add gcode syntax
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.gcode", "*.g", "*.nc"},
    callback = function()
        vim.opt.filetype = 'gcode'
    end
})

vim.api.nvim_create_autocmd("Filetype", {
    pattern = {"html","xml","xsl","php"},
    callback = function()
        vim.cmd(':source ~/.config/nvim/scripts/closetag.vim')
    end
})

-- create dir before save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.cmd(':write ++p')
    end
})
