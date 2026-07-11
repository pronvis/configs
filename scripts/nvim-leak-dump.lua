-- Dump a leaking nvim core's internal state to the report log.
-- Invoked over RPC by nvim-mem-watch.sh when a core's RSS crosses the threshold.
-- The point: turn "an nvim leaked" into "*this category* leaked" so the culprit
-- (a plugin, an LSP, or a giant buffer) is named, not guessed.

local base = os.getenv("XDG_STATE_HOME")
if not base or base == "" then base = os.getenv("HOME") .. "/.local/state" end
local report = base .. "/nvim-leak/report.log"

local f = io.open(report, "a")
if not f then return end
local function w(s) f:write(s .. "\n") end

w(("==== %s pid=%d ===="):format(os.date("%Y-%m-%d %H:%M:%S"), vim.fn.getpid()))
w(("lua_mem_mb=%.1f"):format(collectgarbage("count") / 1024))

-- namespace id -> name, so extmark counts can be attributed to the owning plugin
local ns_name = {}
for name, id in pairs(vim.api.nvim_get_namespaces()) do ns_name[id] = name end

local bufs = vim.api.nvim_list_bufs()
local loaded, total_lines, total_ext = 0, 0, 0
local rows, ns_total = {}, {}
for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(b) then
        loaded = loaded + 1
        local lc = vim.api.nvim_buf_line_count(b)
        total_lines = total_lines + lc
        local bec = 0
        for id, name in pairs(ns_name) do
            local ok, marks = pcall(vim.api.nvim_buf_get_extmarks, b, id, 0, -1, {})
            if ok then
                local n = #marks
                bec = bec + n
                if n > 0 then ns_total[name] = (ns_total[name] or 0) + n end
            end
        end
        total_ext = total_ext + bec
        rows[#rows + 1] = { lc = lc, ec = bec, name = vim.api.nvim_buf_get_name(b) }
    end
end

table.sort(rows, function(a, c) return (a.lc + a.ec) > (c.lc + c.ec) end)
w(("bufs=%d loaded=%d total_lines=%d total_extmarks=%d"):format(#bufs, loaded, total_lines, total_ext))
w("top buffers by size:")
for i = 1, math.min(6, #rows) do
    local nm = rows[i].name
    if nm == "" then nm = "[No Name]" end
    w(("  lines=%-7d extmarks=%-9d %s"):format(rows[i].lc, rows[i].ec, nm))
end

-- extmarks per namespace — points straight at a highlight/diagnostic plugin
-- that is leaking marks (illuminate, rainbow-delimiters, diagnostics, ...).
local ns_rows = {}
for name, n in pairs(ns_total) do ns_rows[#ns_rows + 1] = { name = name, n = n } end
table.sort(ns_rows, function(a, c) return a.n > c.n end)
w("extmarks by namespace (plugin):")
for i = 1, math.min(12, #ns_rows) do
    w(("  %-9d %s"):format(ns_rows[i].n, ns_rows[i].name))
end

local names = {}
for _, c in ipairs(vim.lsp.get_clients()) do names[#names + 1] = c.name end
w(("lsp_clients=%d [%s]"):format(#names, table.concat(names, ",")))
f:close()
