-- Keep one rust-analyzer per nvim instead of one per crate root.
--
-- Jumping into a dependency or the stdlib (`gd` landing in ~/.cargo/registry/…
-- or ~/.rustup/toolchains/…) opens a file outside the workspace, so rustaceanvim
-- resolves a different project root for it. It is written to fold such a root
-- into the running server as an extra workspace folder rather than start a
-- second one — but the check it uses, `vim.lsp.get_clients{ name =
-- 'rust-analyzer' }`, hides clients that have not answered `initialize` yet
-- (nvim's runtime lsp.lua filters on `filter._uninitialized or
-- client.initialized`). Anything that attaches inside that window sees "nothing
-- running" and starts its own server.
--
-- One buffer at a time never hits the window. Attaching many at once always
-- does: `nvim -S` restoring a session, or :ReloadLsp re-firing FileType for
-- every buffer in a loop. That is how one editor ends up with four
-- rust-analyzers — workspace, two registry crates, rustlib — and ~1.2GB.
--
-- The gate below holds external files back while a rust-analyzer is starting,
-- and re-fires FileType once one is initialized so the normal rustaceanvim path
-- runs again and joins it. If none appears within WAIT_LIMIT_MS the file
-- attaches anyway, so a dependency buffer is never stranded without LSP.
--
-- Wired in as `vim.g.rustaceanvim.server.auto_attach`; see after/plugin/lsp.lua.

local M = {}

local POLL_MS = 200
-- rust-analyzer answers `initialize` promptly and does the slow part (cargo
-- metadata, proc macros, indexing) afterwards behind $/progress, so this only
-- has to cover the handshake, not "Building compile-time-deps".
local WAIT_LIMIT_MS = 10000

--- Read-only source trees cargo and rustup unpack crates into. A file here
--- belongs to a dependency, never to the workspace being edited.
--- @return string[]
local function external_roots()
    local cargo = vim.env.CARGO_HOME or vim.fn.expand('~/.cargo')
    local rustup = vim.env.RUSTUP_HOME or vim.fn.expand('~/.rustup')
    return { cargo .. '/registry', cargo .. '/git', rustup .. '/toolchains' }
end

--- @param path string
--- @return boolean
local function is_external(path)
    for _, root in ipairs(external_roots()) do
        if path:sub(1, #root + 1) == root .. '/' then return true end
    end
    return false
end

--- @return boolean ready   a rust-analyzer has finished `initialize`
--- @return boolean starting one is up but still handshaking
local function rust_analyzer_state()
    local ready, starting = false, false
    for _, client in ipairs(vim.lsp.get_clients({ name = 'rust-analyzer', _uninitialized = true })) do
        if client.initialized then ready = true else starting = true end
    end
    return ready, starting
end

--- Buffers whose wait ran out: let the next auto_attach through unconditionally,
--- otherwise re-firing FileType would just re-enter the gate and loop forever.
--- @type table<integer, true>
local expired = {}

--- @type table<integer, true>
local waiting = {}

--- Poll until a rust-analyzer is initialized, then re-fire FileType so the
--- buffer attaches — joining that server instead of starting a rival.
--- @param bufnr integer
--- @param waited integer
local function attach_when_ready(bufnr, waited)
    if not vim.api.nvim_buf_is_loaded(bufnr) then
        waiting[bufnr] = nil
        return
    end

    local ready = rust_analyzer_state()
    if not ready and waited < WAIT_LIMIT_MS then
        vim.defer_fn(function() attach_when_ready(bufnr, waited + POLL_MS) end, POLL_MS)
        return
    end

    waiting[bufnr] = nil
    if not ready then expired[bufnr] = true end
    -- Re-assigning the option fires FileType for exactly this buffer, with no
    -- modeline side effects (the same trick lsp_reload.lua uses).
    vim.bo[bufnr].filetype = vim.bo[bufnr].filetype
end

--- rustaceanvim `server.auto_attach`: whether this buffer may start or join a
--- rust-analyzer. Mirrors the plugin's own default checks, then applies the gate.
--- @param bufnr integer
--- @return boolean
function M.auto_attach(bufnr)
    if vim.bo[bufnr].buftype ~= '' then return false end

    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == '' or vim.fn.filereadable(path) == 0 then return false end

    if not is_external(path) then return true end

    if expired[bufnr] then
        expired[bufnr] = nil
        return true
    end

    local ready = rust_analyzer_state()
    if ready then return true end -- rustaceanvim adds this root to it as a workspace folder

    if not waiting[bufnr] then
        waiting[bufnr] = true
        attach_when_ready(bufnr, 0)
    end
    return false
end

return M
