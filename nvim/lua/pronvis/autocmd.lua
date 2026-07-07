-- prevent accidental writes to buffers that shouldn't be edited
local readonly_group = vim.api.nvim_create_augroup("readonly_group ", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "*.orig", "*.pacnew" },
    group = readonly_group,
    callback = function()
        vim.opt.readonly = true
    end
})

-- View PDFs as extracted text. Neovim can't render PDFs, so on open replace the
-- binary buffer with `pdftotext -layout` output and mark it read-only.
-- Requires poppler: `brew install poppler`.
local pdf_view = vim.api.nvim_create_augroup("pdf_view", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = "*.pdf",
    group = pdf_view,
    callback = function(ev)
        if vim.fn.executable('pdftotext') == 0 then
            vim.notify('pdftotext not found — run `brew install poppler`', vim.log.levels.WARN)
            return
        end
        local name = vim.api.nvim_buf_get_name(ev.buf)
        -- Only convert genuine PDFs (magic bytes "%PDF-"). A file that merely has
        -- a .pdf extension but is actually text is left as-is so nvim just shows it.
        local fh = io.open(name, 'rb')
        if not fh then return end
        local magic = fh:read(5)
        fh:close()
        if magic ~= '%PDF-' then return end
        -- systemlist with a list arg: no shell, no quoting, reads the file directly.
        local out = vim.fn.systemlist({ 'pdftotext', '-layout', '-nopgbrk', name, '-' })
        if vim.v.shell_error ~= 0 then
            vim.notify('pdftotext failed on ' .. name, vim.log.levels.WARN)
            return
        end
        vim.bo[ev.buf].modifiable = true
        vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, out)
        vim.bo[ev.buf].modified = false
        vim.bo[ev.buf].modifiable = false
        vim.bo[ev.buf].readonly = true
    end
})

-- follow Rust code style rules
local rust_spacetabs = vim.api.nvim_create_augroup("rust_spacetabs", { clear = true })
vim.api.nvim_create_autocmd({ "Filetype" }, {
    pattern = "rust",
    group = rust_spacetabs,
    callback = function()
        vim.cmd(':source ~/.config/nvim/scripts/rust_spacetab.vim')
        vim.opt.colorcolumn = ''
    end
})

-- treat .jsonl as json so it gets JSON syntax highlighting
vim.filetype.add({ extension = { jsonl = 'json' } })

-- help filetype detection
local gnuplot_syntax = vim.api.nvim_create_augroup("gnuplot_syntax", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = "*.plot",
    group = gnuplot_syntax,
    callback = function()
        vim.opt.filetype = 'gnuplot'
    end
})
local markdown_syntax = vim.api.nvim_create_augroup("markdown_syntax", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = "*.md",
    group = markdown_syntax,
    callback = function()
        vim.opt.filetype = 'markdown'
    end
})

-- add gcode syntax
local gcode_group = vim.api.nvim_create_augroup("gcode_group", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.gcode", "*.g", "*.nc" },
    group = gcode_group,
    callback = function()
        vim.opt.filetype = 'gcode'
    end
})

local closetag_group = vim.api.nvim_create_augroup("closetag_group", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
    pattern = { "html", "xml", "xsl", "php" },
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
    callback = function()
        vim.hl.on_yank { silent = true, higroup = 'IncSearch', timeout = 300 }
    end
})

-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
    group = "lualine_augroup",
    pattern = "LspProgressStatusUpdated",
    callback = require("lualine").refresh,
})

-- :ClaudeLog  → full conversation as readable text (your prompts + Claude's
--               replies, labeled) in a scratch buffer.
-- :ClaudeLog! → the raw jsonl transcript file (structured, json-highlighted).
-- Transcripts live at ~/.claude/projects/<cwd-with-slashes-as-dashes>/<session>.jsonl
vim.api.nvim_create_user_command('ClaudeLog', function(o)
    local dir = vim.fn.expand('~/.claude/projects/') .. vim.fn.getcwd():gsub('/', '-')
    local file = vim.fn.system({ 'sh', '-c', 'ls -t "' .. dir .. '"/*.jsonl 2>/dev/null | head -1' })
        :gsub('%s+$', '')
    if file == '' then
        vim.notify('no Claude transcript for this project (' .. dir .. ')', vim.log.levels.WARN)
        return
    end
    if o.bang then -- raw jsonl (highlighted as json via ftplugin)
        vim.cmd('edit ' .. vim.fn.fnameescape(file))
    else -- text-only scratch buffer: full labeled conversation
        -- both user + assistant text blocks; tool_result/tool_use blocks skipped.
        local prog = 'select(.type=="user" or .type=="assistant") | (.type) as $t | '
            .. '(if (.message.content|type)=="string" then [.message.content] '
            .. 'else [.message.content[]?|select(.type=="text")|.text] end) | .[] | '
            .. '(if $t=="user" then "\\n\\n===== YOU =====\\n" else "\\n\\n===== CLAUDE =====\\n" end) + .'
        vim.cmd('enew')
        vim.cmd(([[r !jq -r '%s' %s]]):format(prog, vim.fn.shellescape(file)))
        vim.bo.buftype = 'nofile'
        vim.bo.bufhidden = 'wipe'
        vim.bo.filetype = 'markdown'
    end
end, { bang = true, desc = 'Claude transcript: full text (! = raw jsonl)' })
