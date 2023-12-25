-- prevent accidental writes to buffers that shouldn't be edited
local readonly_group = vim.api.nvim_create_augroup("readonly_group ", { clear = true })
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = {"*.orig", "*.pacnew"},
    group = readonly_group,
    callback = function()
        vim.opt.readonly = true
    end
})

-- follow Rust code style rules
local rust_spacetabs = vim.api.nvim_create_augroup("rust_spacetabs", { clear = true })
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = "rust",
    group = rust_spacetabs,
    callback = function()
        vim.cmd(':source ~/.config/nvim/scripts/rust_spacetab.vim')
        vim.opt.colorcolumn=''
    end
})

-- help filetype detection
local gnuplot_syntax = vim.api.nvim_create_augroup("gnuplot_syntax", { clear = true })
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = "*.plot",
    group = gnuplot_syntax,
    callback = function()
        vim.opt.filetype = 'gnuplot'
    end
})
local markdown_syntax = vim.api.nvim_create_augroup("markdown_syntax", { clear = true })
vim.api.nvim_create_autocmd({"BufRead"}, {
    pattern = "*.md",
    group = markdown_syntax,
    callback = function()
        vim.opt.filetype = 'markdown'
    end
})

-- add gcode syntax
local gcode_group = vim.api.nvim_create_augroup("gcode_group", { clear = true })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.gcode", "*.g", "*.nc"},
    group = gcode_group,
    callback = function()
        vim.opt.filetype = 'gcode'
    end
})

local closetag_group = vim.api.nvim_create_augroup("closetag_group", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
    pattern = {"html","xml","xsl","php"},
    group = closetag_group,
    callback = function()
        vim.cmd(':source ~/.config/nvim/scripts/closetag.vim')
    end
})

-- create dir before save
local create_dir = vim.api.nvim_create_augroup("create_dir", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    group = create_dir,
    callback = function()
        vim.cmd(':write ++p')
    end
})

-- highlight on yanking
local highlight_yank = vim.api.nvim_create_augroup("highlight_yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    group = highlight_yank,
    callback = function ()
	    vim.highlight.on_yank{silent = true, higroup = 'IncSearch', timeout = 300}
    end
})

