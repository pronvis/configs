-- Swap-file policy.
--
-- With many nvim instances alive at once (tmux session restore routinely brings
-- back dozens), the same file is often already open elsewhere. Neovim's default
-- reaction is the interactive "E325: ATTENTION" dialog — which is not just noisy:
-- when a plugin loads a buffer from inside a coroutine (diffview opening the
-- LOCAL side of a diff via nvim_win_set_buf) the raised E325 propagates as an
-- error and tears down the whole operation.
--
-- Answering via `v:swapchoice` in a SwapExists autocmd skips the dialog, so no
-- error is raised. The policy below is deliberately conservative: it only
-- auto-answers when doing so cannot lose work.
--
--   swap has unsaved changes  -> fall through to the normal dialog (never guess)
--   owner process still alive -> 'o' open read-only (another nvim owns the file)
--   stale swap, no changes    -> 'd' delete it and open normally
--
-- To make diffview's local pane editable instead of read-only, change 'o' to 'e'
-- below — at the cost of two instances being able to write the same file.

local M = {}

--- Is a process with this pid currently running?
--- Signal 0 performs the permission/existence check without delivering anything.
--- @param pid integer|nil
--- @return boolean
local function process_alive(pid)
    if not pid or pid <= 0 then return false end
    local ok = pcall(vim.uv.kill, pid, 0)
    return ok
end

--- Working directory of a running process.
--- macOS has no /proc, so ask lsof for the process's cwd descriptor.
--- The wait is bounded: a wedged lsof (stale network mount) must not hold up
--- the swap prompt.
--- @param pid integer
--- @return string|nil
local function process_cwd(pid)
    local ok, res = pcall(function()
        return vim
            .system({ 'lsof', '-a', '-d', 'cwd', '-Fn', '-w', '-p', tostring(pid) }, { text = true })
            :wait(500)
    end)
    if not ok or res.code ~= 0 or not res.stdout then return nil end

    -- -Fn output is one field per line: `p<pid>`, `fcwd`, `n<path>`.
    for line in res.stdout:gmatch('[^\n]+') do
        local path = line:match('^n(/.*)$')
        if path then return path end
    end
end

--- Decide how to answer the swap prompt for `swapname`.
--- @param swapname string
--- @return string|nil choice a `v:swapchoice` value, or nil to show the dialog
--- @return table|nil info the parsed swap info, when it was readable
local function choose(swapname)
    local ok, info = pcall(vim.fn.swapinfo, swapname)

    -- Unreadable or malformed swap file: let the user see the real dialog.
    if not ok or type(info) ~= 'table' or info.error then return nil end

    -- Unsaved changes live only in this swap file — always ask.
    if tonumber(info.dirty) == 1 then return nil, info end

    if process_alive(tonumber(info.pid)) then return 'o', info end

    return 'd', info
end

function M.setup()
    local group = vim.api.nvim_create_augroup('pronvis_swapfile', { clear = true })

    vim.api.nvim_create_autocmd('SwapExists', {
        group = group,
        callback = function()
            local choice, info = choose(vim.v.swapname)
            if not choice then return end -- fall through to the normal dialog

            vim.v.swapchoice = choice

            if choice == 'o' then
                local pid = tonumber(info.pid)
                local cwd = process_cwd(pid)
                vim.notify(
                    ('%s is open in another nvim (pid %d%s) — opened read-only')
                    :format(
                        vim.fn.fnamemodify(vim.v.swapname, ':t'),
                        pid,
                        cwd and (', cwd ' .. cwd) or ''
                    ),
                    vim.log.levels.INFO
                )
            end
        end,
    })
end

return M
