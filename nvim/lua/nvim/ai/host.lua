local M = {}

-- Detect WSL by checking the kernel version string for "Microsoft"/"microsoft".
local handle = io.popen("uname -r 2>/dev/null")
local uname_r = handle and handle:read("*l") or ""
if handle then handle:close() end
local is_wsl = (uname_r:lower():find("microsoft") ~= nil)
    or (vim.fn.filereadable("/proc/sys/fs/binfmt_misc/WSLInterop") == 1)

-- Host probing is asynchronous so it never blocks UI startup. The resolved
-- host is cached for the rest of the session (and across rebuilds), so the
-- expensive probe runs only once.

---Return true if TCP connect to host:port succeeds, probed with a short
---timeout. Uses vim.uv via a background bash /dev/tcp probe so we never block.
local function socket_ok(host, port, callback)
    local cmd = string.format(
        "timeout 2 bash -c 'exec 3<>/dev/tcp/%s/%s' 2>/dev/null",
        host, port
    )
    vim
        .system({ "bash", "-c", cmd }, { text = true })
        :wait(2, function(res)
            callback(res and res.code == 0)
        end)
end

-- Ordered candidates for the host that runs Ollama.
--
--WSL2's networking mode decides the right host:
--  * Mirrored networking: the Windows host (that runs Ollama) IS on localhost,
--    and host.docker.internal / the default gateway may point at unreachable
--    containers. localhost must be tried first.
--  * NAT networking: localhost is WSL itself, so the Windows host is reached
--    via host.docker.internal or the default gateway instead.
--We probe every candidate in order and return whichever answers, which works
--regardless of the networking mode.
local function candidates()
    local list = { "127.0.0.1" }

    if is_wsl then
        local gp = io.popen("getent hosts host.docker.internal 2>/dev/null | awk '{print $1}'")
        local docker_ip = gp and gp:read("*l") or ""
        if gp then gp:close() end
        if docker_ip and docker_ip:match("%d+%.%d+%.%d+%.%d+")
            and docker_ip ~= "0.0.0.0" and docker_ip ~= "127.0.0.1" then
            list[#list + 1] = docker_ip
        end

        local rp = io.popen("ip route show default 2>/dev/null | awk '{print $3}'")
        local gw = rp and rp:read("*l") or ""
        if rp then rp:close() end
        if gw and gw:match("%d+%.%d+%.%d+%.%d+") then
            list[#list + 1] = gw
        end
    end

    list[#list + 1] = "localhost"
    return list
end

local resolved

---Asynchronously resolve (and cache) which candidate host actually runs
---Ollama, then invoke callback(found). Runs at most once per session.
function M.resolve(callback)
    if resolved then
        if callback then callback(resolved) end
        return
    end
    local list = candidates()
    local i = 1
    local function next_candidate()
        if i > #list then
            resolved = "127.0.0.1"
            if callback then callback(resolved) end
            return
        end
        local host = list[i]
        i = i + 1
        socket_ok(host, 11434, function(ok)
            if ok then
                resolved = host
                if callback then callback(resolved) end
            else
                next_candidate()
            end
        end)
    end
    next_candidate()
end

---Return the Ollama host as a base URL. Synchronous: returns the cached host
---immediately if already resolved, otherwise a fast `127.0.0.1` default while
---kicking off async resolution (which updates the cache and notifies the user
---if a different host was found). Never blocks the UI.
function M.ollama_host()
    if resolved then
        return resolved
    end
    M.resolve(function(found)
        if found ~= "127.0.0.1" then
            vim.schedule(function()
                vim.notify("Ollama detected on " .. found, vim.log.levels.INFO)
            end)
        end
    end)
    return "127.0.0.1"
end

local cached_base
function M.ollama_base(port)
    port = port or 11434
    -- Re-derive from ollama_host() each call: it is cheap once resolved, and
    -- this lets the base URL pick up an async-resolved non-localhost host.
    return "http://" .. M.ollama_host() .. ":" .. port
end

return M
