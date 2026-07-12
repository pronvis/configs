-- Custom tabline: clean labels + settable per-tab names.
--
-- Neovim has no native "tab name" — the default tabline derives the label from
-- the active buffer's name and path-shortens it into an unreadable mash (e.g. a
-- `term://…` buffer becomes `t//~/i/k/r//8/U/p/.l/b/claude`). Here each tab
-- shows either a name you set (`t:tabname`) or just the file's tail.
--
--   :TabRename my-notes   name the current tab
--   :TabRename            clear the name (back to the filename)
--   <leader>tr            prompt to rename (keymap lives in remap.lua)

-- Label for tab number `i`: custom name > filename tail > [No Name].
local function tab_label(i)
    local custom = vim.fn.gettabvar(i, 'tabname', '')
    if custom ~= '' then return custom end

    local buflist = vim.fn.tabpagebuflist(i)
    local bufnr = buflist[vim.fn.tabpagewinnr(i)]
    local name = vim.fn.bufname(bufnr)
    if name == '' then return '[No Name]' end

    if vim.bo[bufnr].buftype == 'terminal' then
        -- term://<cwd>//<pid>:<cmd>  →  show just the command's basename
        local cmd = name:match(':([^:]+)$') or name
        return vim.fn.fnamemodify(cmd, ':t')
    end
    return vim.fn.fnamemodify(name, ':t')
end

-- Built as a %!-expression so it re-renders on every redraw.
function _G.pronvis_tabline()
    local parts = {}
    local cur = vim.fn.tabpagenr()
    for i = 1, vim.fn.tabpagenr('$') do
        local hl = (i == cur) and '%#TabLineSel#' or '%#TabLine#'
        local label = tab_label(i):gsub('%%', '%%%%') -- escape % for the statusline parser
        local mod = ''
        for _, b in ipairs(vim.fn.tabpagebuflist(i)) do
            if vim.bo[b].modified then mod = ' ●'; break end
        end
        -- %<i>T … %T makes the label clickable to switch to that tab.
        parts[#parts + 1] = ('%s%%%dT %d %s%s '):format(hl, i, i, label, mod)
    end
    return table.concat(parts) .. '%#TabLineFill#%T'
end

vim.o.tabline = '%!v:lua.pronvis_tabline()'

vim.api.nvim_create_user_command('TabRename', function(o)
    if o.args == '' then
        vim.cmd('unlet! t:tabname')
    else
        vim.t.tabname = o.args
    end
    vim.cmd.redrawtabline()
end, { nargs = '?', desc = 'Rename current tab (no arg clears it)' })
