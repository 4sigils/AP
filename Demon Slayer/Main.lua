local GAME_NAME = "Demon://Slayer"
local LOG_TAG   = "[Demon://Slayer]"

local IGNORE_URL = "https://raw.githubusercontent.com/4sigils/AP/refs/heads/main/Demon%20Slayer/IgnoredAnimations.lua"
local ANIM_URL   = "https://raw.githubusercontent.com/4sigils/AP/refs/heads/main/Demon%20Slayer/Animations.lua"

local LOGO_URL = "https://cdn.discordapp.com/attachments/1402876855840804895/1558405775167201400/noFilter_1.png?ex=6acb51fa&is=6aca007a&hm=8ff9153ff0a850fa34512fbe989660978c0583fa43b6a417caac6a61de7189fd&"
local BG_IMG   = "\137\080\078\071\013\010\026\010\000\000\000\013\073\072\068\082\000\000\000\004\000\000\000\004\008\006\000\000\000\169\241\158\126\000\000\000\079\073\068\065\084\120\001\001\068\000\187\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\006\090\015\241\170\028\251\110\000\000\000\000\073\069\078\068\174\066\096\130"

local KEY_PARRY  = 0x46 -- F
local KEY_DODGE  = 0x51 -- Q
local KEY_JUMP   = 0x20 -- Space
local KEY_E      = 0x45 -- E

-- All animation timings in the data file are tuned for roughly this ping (ms).
local BASE_PING = 60

-- Used for an animation that has no base distance in the data file while "Use General Range" is off.
local DEFAULT_ANIM_RANGE = 20

local SCAN_INTERVAL = 0.018
local HIST_SLOTS = 10

-- DRAWING TRACKER
-- Nexa:Destroy() does not always remove everything the UI drew (the window background and logos can stay on screen),
-- so every Drawing object created while this script runs (this includes the Nexa UI, which is loaded below) is
-- recorded here and removed by Unload. Keys are weak, so objects the UI already dropped are still garbage collected.
local TrackedDrawings = setmetatable({}, { __mode = "k" })
local OrigDrawingNew, DrawingLib = nil, nil
do
    local okD, lib = pcall(function() return Drawing end)
    if okD and type(lib) == "table" and type(lib.new) == "function" then
        DrawingLib, OrigDrawingNew = lib, lib.new
        local okSet = pcall(function()
            lib.new = function(...)
                local obj = OrigDrawingNew(...)
                if obj ~= nil then TrackedDrawings[obj] = true end
                return obj
            end
        end)
        if not okSet then DrawingLib, OrigDrawingNew = nil, nil end
    end
end

-- hides and removes every tracked Drawing; returns how many it handled
local function RemoveTrackedDrawings()
    local n = 0
    for obj in pairs(TrackedDrawings) do
        TrackedDrawings[obj] = nil
        pcall(function() obj.Visible = false end)
        if not pcall(function() obj:Remove() end) then
            pcall(function() obj:Destroy() end)
        end
        n = n + 1
    end
    return n
end

-- NEXA UI LOADER
local Nexa
do
local NEXA_SOURCE = "https://raw.githubusercontent.com/OgTen/Nexa-UI/refs/heads/main/nexa-ui.lua"

local function isNexaLibrary(value)
    return type(value) == "table"
        and type(value.CreateWindow) == "function"
        and type(value.AddTab) == "function"
        and type(value.Notify) == "function"
end

local function findExportedNexa()
    local env = type(getgenv) == "function" and getgenv() or nil
    local candidates = {}
    if env then
        candidates[#candidates + 1] = env.Nexa
        candidates[#candidates + 1] = env.UI
        candidates[#candidates + 1] = env.DrawingUI
    end
    candidates[#candidates + 1] = rawget(_G, "Nexa")
    candidates[#candidates + 1] = rawget(_G, "UI")
    candidates[#candidates + 1] = rawget(_G, "DrawingUI")
    if type(shared) == "table" then
        candidates[#candidates + 1] = shared.Nexa
        candidates[#candidates + 1] = shared.UI
        candidates[#candidates + 1] = shared.DrawingUI
    end
    for _, candidate in ipairs(candidates) do
        if isNexaLibrary(candidate) then return candidate end
    end
    return nil
end

local function getNexa()
    local old = findExportedNexa()
    if old then pcall(function() old:Destroy() end) end

    if type(loadstring) ~= "function" then
        error(LOG_TAG .. " This environment does not provide loadstring.")
    end

    local okHttp, source = pcall(function() return game:HttpGet(NEXA_SOURCE) end)
    if not okHttp then error(LOG_TAG .. " Failed to download Nexa: " .. tostring(source)) end
    if type(source) ~= "string" or #source < 100 then
        error(LOG_TAG .. " Nexa download returned invalid/empty source.")
    end

    -- Notifications were drawn with the window's fade alpha, which is 0 while the menu is closed:
    -- the box and text vanished and only the (image) logo stayed visible. Draw them at full alpha.
    local patchedSource, notifPatches = string.gsub(source, "\n([ \t]*)DrawNotifications%(%)", function(indent)
        return "\n" .. indent .. "do local __pa = FrameAlpha FrameAlpha = 1 DrawNotifications() FrameAlpha = __pa end"
    end)
    if notifPatches > 0 then
        source = patchedSource
    else
        warn(LOG_TAG .. " Nexa notification patch point not found; notifications may only show the logo while the menu is closed.")
    end

    -- Input lock fix: the menu blocks the game's keyboard / mouse / camera input while the cursor is over it.
    -- The cursor position stops updating once you leave the Roblox window, so while you are in another window
    -- (for example clicking Eject in the executor) it still counts as "over the menu", and if the script is
    -- ejected then, the lock is never released and you can't move or look around. Don't capture input while
    -- the Roblox window isn't focused, so the lock is already gone by the time you eject.
    local focusPatched, focusPatches = string.gsub(source, "local function GameCaptures%(%)", function()
        return [[local function GameCaptures()
        do
            local activeFn = isrbxactive or iswindowactive or isrobloxactive
            if type(activeFn) == "function" then
                local okActive, active = pcall(activeFn)
                if okActive and active == false then return false end
            end
        end]]
    end, 1)
    if focusPatches > 0 then
        source = focusPatched
    else
        warn(LOG_TAG .. " Nexa input patch point not found; the menu may keep game input locked after an eject.")
    end

    local chunk, compileError = loadstring(source)
    if not chunk then error(LOG_TAG .. " Nexa failed to compile: " .. tostring(compileError)) end

    local okRun, returned = pcall(chunk)
    if not okRun then error(LOG_TAG .. " Nexa failed while executing: " .. tostring(returned)) end

    if isNexaLibrary(returned) then return returned end
    local exported = findExportedNexa()
    if exported then return exported end

    error(LOG_TAG .. " Nexa executed, but no compatible Library API was exported.")
end

Nexa = getNexa()
end

local Controls = {}
local ConfigDirty = false -- set whenever a registered control changes; the autosave loop only writes when this is true
local function Reg(flag, ctrl)
    Controls[flag] = ctrl
    ctrl:OnChanged(function() ConfigDirty = true end)
    return ctrl
end
local function Get(flag)
    local c = Controls[flag]
    if c then return c:GetValue() end
    return nil
end

-- MEMORY / OFFSETS
local offsets = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://offsets.imtheo.lol/Offsets.json")).Offsets
local KnownOffsets = {
    AnimationId      = offsets.Misc.AnimationId,
    ClassDescriptor  = offsets.Instance.ClassDescriptor,
    ClassName        = offsets.Instance.ClassName,
    TimePosition     = offsets.AnimationTrack.TimePosition or 0xD8,
    ActiveAnimations = offsets.Animator.ActiveAnimations,
    NodeNext         = 0x10,
}
local OFF_ANIM = offsets.AnimationTrack.Animation

local function ReadPointer(addr)
    local ok, v = pcall(memory_read, "uintptr_t", addr)
    if ok and v and v > 4096 then return v end
    return nil
end

local function ReadString(addr)
    if not addr or addr <= 4096 then return nil end
    local ok, s = pcall(memory_read, "string", addr)
    return ok and s or nil
end

local function GetClassName(addr)
    if not addr or addr <= 4096 then return "Invalid" end
    local desc = ReadPointer(addr + KnownOffsets.ClassDescriptor)
    if not desc then return "Error" end
    return ReadString(ReadPointer(desc + KnownOffsets.ClassName)) or "Unknown"
end

local function CleanId(id)
    return id and tostring(id):match("%d+")
end

-- ENEMIES
local Players = game:GetService("Players")

local function CleanName(name)
    return (tostring(name):gsub("^%.", ""))
end

-- Name for logs: no leading dot and no trailing " [uuid]" tag ("Slayer [57c5d91e-...]" -> "Slayer")
local function DisplayName(name)
    local cleaned = CleanName(name)
    local short = (cleaned:gsub("%s*%[[^%]]*%]%s*$", ""))
    return short ~= "" and short or cleaned
end

local AnimCache, AnimCacheN = {}, 0
local AnimatorCache, AnimatorCacheN = {}, 0

local function GetAnimatorAddr(model)
    local key = model.Address
    local addr = AnimatorCache[key]
    if addr then return addr end

    local hum = model:FindFirstChild("Humanoid")
    local animator = hum and hum:FindFirstChild("Animator")
    if not animator then return nil end

    if AnimatorCacheN > 300 then AnimatorCache, AnimatorCacheN = {}, 0 end
    addr = animator.Address
    AnimatorCache[key] = addr
    AnimatorCacheN = AnimatorCacheN + 1
    return addr
end

local function FactionAttr(m) return m:GetAttribute("Faction") end
-- "Slayer" / "Demon" from a character model's Faction attribute, nil if it has none
local function GetFaction(model)
    local ok, f = pcall(FactionAttr, model)
    if ok and type(f) == "string" and f ~= "" then return f end
    return nil
end

local MyFaction = nil -- the local player's Faction attribute, refreshed with the enemy list

local Enemies, NextRefresh = {}, 0
local EnemyCache = {}
local LocalHRP = nil

local function BuildEntry(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local animator = hrp and GetAnimatorAddr(model)
    if not animator then return nil end
    local name = CleanName(model.Name)
    return {
        model = model,
        name = name,
        lname = string.lower(name),
        key = tostring(model.Address),
        hrp = hrp,
        animator = animator,
        isPlayer = Players:FindFirstChild(name) ~= nil,
        skipUntil = 0,
        factionAt = 0,
    }
end

local function RefreshEnemies(now)
    local list, nextCache = {}, {}
    local lp = Players.LocalPlayer
    LocalHRP = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") or nil

    local live = workspace:FindFirstChild("Alive")
    if not live then Enemies, EnemyCache = list, nextCache return end

    local myName = lp and lp.Name
    local me = (myName and live:FindFirstChild(myName)) or (lp and lp.Character)
    MyFaction = me and GetFaction(me) or nil

    for _, model in ipairs(live:GetChildren()) do
        local addr = model.Address
        local cached = EnemyCache[addr]
        if cached and cached.dead and now < cached.retryAt then
            nextCache[addr] = cached
        else
            local entry = (cached and not cached.dead and not cached.stale) and cached or BuildEntry(model)
            if entry then
                nextCache[addr] = entry
                -- factions rarely change, so only re-read them every couple of seconds
                if entry.isPlayer and now >= entry.factionAt then
                    entry.factionAt = now + 2
                    entry.faction = GetFaction(model)
                end
                if entry.name ~= myName then list[#list + 1] = entry end
            else
                nextCache[addr] = {dead = true, retryAt = now + 3}
            end
        end
    end
    Enemies, EnemyCache = list, nextCache
end

local function DistFn(a, b) return (a.Position - b.Position).Magnitude end
local function Dist(enemy)
    if not LocalHRP then return math.huge end
    local ok, d = pcall(DistFn, LocalHRP, enemy.hrp)
    return ok and d or math.huge
end

local function GetPlayingAnims(enemy)
    local out = {}
    local addr = enemy.animator or GetAnimatorAddr(enemy.model)
    if not addr then return out end

    local listHead = ReadPointer(addr + KnownOffsets.ActiveAnimations)
    if not listHead then
        AnimatorCache[enemy.model.Address] = nil
        enemy.stale = true
        return out
    end

    local node, count = ReadPointer(listHead), 0
    while node and node ~= listHead and count < 50 do
        count = count + 1
        local track = ReadPointer(node + KnownOffsets.NodeNext)
        local anim = track and ReadPointer(track + OFF_ANIM)
        if anim then
            local id = AnimCache[anim]
            if id == nil then
                id = false
                if GetClassName(anim) == "Animation" then
                    id = CleanId(ReadString(ReadPointer(anim + KnownOffsets.AnimationId))) or false
                end
                if AnimCacheN > 800 then AnimCache, AnimCacheN = {}, 0 end
                AnimCache[anim] = id
                AnimCacheN = AnimCacheN + 1
            end
            if id then
                local ok, t = pcall(memory_read, "float", track + KnownOffsets.TimePosition)
                local good = ok and type(t) == "number" and t == t and t >= 0 and t < 30
                out[#out + 1] = {id = id, elapsed = good and t or 0, track = track}
            end
        end
        node = ReadPointer(node)
    end
    return out
end

local function IsAnimAlive(model, id)
    if not model or not id then return false end
    for _, anim in ipairs(GetPlayingAnims({model = model})) do
        if anim.id == id then return true end
    end
    return false
end

local Releases = {}
local function PressKey(vk, holdSeconds)
    local ok = pcall(keypress, vk)
    if not ok then
        print(LOG_TAG .. " keypress() failed - your executor may name it differently")
        return
    end
    Releases[#Releases + 1] = {at = os.clock() + (holdSeconds or 0.05), vk = vk}
end

local function HttpGet(url)
    local attempts = {
        function() return game:HttpGet(url) end,
        function()
            local req = request or http_request or (syn and syn.request)
            local res = req and req({Url = url, Method = "GET"})
            return res and res.Body
        end,
    }
    for _, try in ipairs(attempts) do
        local ok, body = pcall(try)
        -- GitHub returns the literal text "404: Not Found" for bad URLs; don't treat that as data
        if ok and type(body) == "string" and #body > 0 and not body:match("^%s*404:") then
            return body
        end
    end
    return nil
end

-- PING
-- Matcha provides its own global GetPingValue(). Grab it here, BEFORE the local GetPingValue below is
-- declared, otherwise the local shadows it and the native function is never called.
local NativeGetPingValue = GetPingValue
if type(NativeGetPingValue) ~= "function" and type(getgenv) == "function" then
    local ok, fn = pcall(function() return getgenv().GetPingValue end)
    if ok and type(fn) == "function" then NativeGetPingValue = fn end
end
if type(NativeGetPingValue) ~= "function" then NativeGetPingValue = nil end

local PingMethod = "none"
local PingError = nil

local function ValidPing(v)
    return type(v) == "number" and v == v and v > 0 and v < 10000
end

-- tried in order until one returns a usable number (executors differ in what they expose)
local PING_METHODS = {
    { "native GetPingValue", function()
        if not NativeGetPingValue then error("no native GetPingValue global") end
        return NativeGetPingValue()
    end },
    { "Data Ping", function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end },
    { "Data Ping (string)", function()
        local s = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        return tonumber(tostring(s):match("[%d%.]+"))
    end },
    { "PerformanceStats.Ping", function()
        return game:GetService("Stats").PerformanceStats.Ping:GetValue()
    end },
    -- Matcha-style access: FindFirstChild + property read instead of method calls
    { "FindFirstChild .Value", function()
        local stats = game:GetService("Stats")
        local net = stats:FindFirstChild("Network")
        local sItem = net and net:FindFirstChild("ServerStatsItem")
        local item = sItem and sItem:FindFirstChild("Data Ping")
        return item and item.Value
    end },
    { "FindFirstChild GetValue", function()
        local stats = game:GetService("Stats")
        local net = stats:FindFirstChild("Network")
        local sItem = net and net:FindFirstChild("ServerStatsItem")
        local item = sItem and sItem:FindFirstChild("Data Ping")
        return item and item:GetValue()
    end },
    { "PerformanceStats .Value", function()
        local item = game:GetService("Stats").PerformanceStats:FindFirstChild("Ping")
        return item and item.Value
    end },
    { "GetNetworkPing", function()
        return Players.LocalPlayer:GetNetworkPing() * 1000
    end },
}

local function GetPingMs()
    local errs = {}
    for _, method in ipairs(PING_METHODS) do
        local ok, v = pcall(method[2])
        if ok and ValidPing(v) then
            PingMethod, PingError = method[1], nil
            return v
        end
        errs[#errs + 1] = method[1] .. ": " .. tostring(ok and ("returned " .. tostring(v)) or v)
    end
    PingMethod, PingError = "none", table.concat(errs, "\n" .. LOG_TAG .. "   ")
    return nil
end

local function GetPingValue()
    return GetPingMs()
end

local function PingToComp(ping)
    local comp = math.floor(ping - BASE_PING + 0.5)
    return math.max(-BASE_PING, math.min(300, comp))
end

-- AUTO PING COMP (live ping, smoothed with a 0.25 factor, compensate the one-way trip = ping / 2,
-- and no compensation at all under 25 ms)
local AutoPing = { smoothing = 0.25, min = 25, max = 300, smooth = nil, at = 0, comp = 0 }

local function UpdateAutoPing(now)
    if now - AutoPing.at < 0.2 then return end
    local raw = GetPingMs()
    if not raw then return end

    if AutoPing.smooth == nil or now - AutoPing.at > 1.5 then
        AutoPing.smooth = raw -- first sample or a long gap: start fresh
    else
        AutoPing.smooth = AutoPing.smooth + (raw - AutoPing.smooth) * AutoPing.smoothing
    end
    AutoPing.at = now

    if AutoPing.smooth < AutoPing.min then
        AutoPing.comp = 0
    else
        AutoPing.comp = math.min(AutoPing.smooth / 2, AutoPing.max)
    end
end

-- ms to fire earlier: automatic when "Auto Ping Comp" is on, otherwise the Ping Comp slider
local function GetPingComp()
    local auto = Controls.sb_t_autoping
    if auto and auto.Value then
        UpdateAutoPing(os.clock())
        return AutoPing.comp
    end
    return Get("sb_t_ping") or 0
end

-- STATE
local AnimDB      = {}
local AnimMaxRange = 0 -- largest base distance in the data file (sets how far out enemies are scanned)
local AnimCategories = {} -- sorted names of the top-level groups in the data file (Claws, Katana, ...)
local CategoryDD = nil -- the Debug tab's category dropdown, filled in once the Debug tab exists
local NO_CATEGORY = "Ungrouped"
local Active      = {}
local Queue       = {}
local Status      = {loaded = 0, ignored = 0, tracked = 0, last = "none", lastDist = 0, loopMs = 0, scanMs = 0, ping = 0, feint = "-"}

local function Log(msg) print(LOG_TAG .. " " .. tostring(msg)) end

-- "Katana M1" for an animation that is in the data file, "rbxassetid://123" for one that isn't
local function AnimLabel(id)
    local info = AnimDB[tostring(id)]
    if info and info.name then return info.name end
    return "rbxassetid://" .. tostring(id)
end

-- "Katana M1 | 103121348089957" (name | id); "Unknown | id" when the animation isn't in the data file
local function AnimNameId(id)
    local info = AnimDB[tostring(id)]
    return (info and info.name or "Unknown") .. " | " .. tostring(id)
end

-- ANIMATION DATA
-- Entry formats: number | { t1, t2 } | { type = "parry", t = {..}, unparryable = true } | { { type = "jump", t = 0.4 }, ... }
-- types: parry (F, or Q when the Dodging options swap it), dodge (always Q), unparryable (Q), jump
-- Moves can also be grouped and named: Claws = { M1 = { id = 123, type = "parry", t = 0.4 }, M2 = { ... } }
-- (see Flatten below for every supported layout; a group's `range` is the default for its moves)
-- Base distance (studs) per animation: add `range = 15` (or `distance` / `dist`) to the entry, e.g.
--   ["rbxassetid://123"] = { type = "parry", t = 0.4, range = 15 }
-- or put it on one item of a list. Used unless "Use General Range" is on.

local function ParseLua(src)
    local pos, len = 1, #src
    local parseValue

    local function skip()
        while pos <= len do
            local _, ws = src:find("^%s+", pos)
            if ws then pos = ws + 1 end
            if src:sub(pos, pos + 1) == "--" then
                local lvl = src:match("^%-%-%[(=*)%[", pos)
                if lvl then
                    local _, e = src:find("]" .. lvl .. "]", pos, true)
                    pos = e and e + 1 or len + 1
                else
                    local nl = src:find("\n", pos, true)
                    pos = nl and nl + 1 or len + 1
                end
            elseif not ws then
                break
            end
        end
    end

    local function parseTable()
        pos = pos + 1
        local t, n = {}, 0
        while pos <= len do
            skip()
            local c = src:sub(pos, pos)
            if c == "}" then pos = pos + 1 break end
            if c == "" then break end

            if c == "[" then
                pos = pos + 1
                local k = parseValue()
                skip(); pos = pos + 1
                skip(); pos = pos + 1
                t[k] = parseValue()
            else
                local name = src:match("^([%a_][%w_]*)%s*=", pos)
                if name then
                    pos = pos + #name
                    skip(); pos = pos + 1
                    t[name] = parseValue()
                else
                    n = n + 1
                    t[n] = parseValue()
                end
            end

            skip()
            local sep = src:sub(pos, pos)
            if sep == "," or sep == ";" then pos = pos + 1 end
        end
        return t
    end

    parseValue = function()
        skip()
        local c = src:sub(pos, pos)
        if c == "{" then return parseTable() end
        if c == '"' or c == "'" then
            local e = src:find(c, pos + 1, true) or len
            local s = src:sub(pos + 1, e - 1)
            pos = e + 1
            return s
        end
        local num = src:match("^-?[%d%.]+", pos)
        if num then pos = pos + #num return tonumber(num) end
        local word = src:match("^[%a_][%w_]*", pos)
        if word then
            pos = pos + #word
            if word == "true" then return true end
            if word == "false" then return false end
            return nil
        end
        pos = pos + 1
        return nil
    end

    skip()
    if src:match("^return", pos) then pos = pos + 6 end
    local value = parseValue()
    return value, pos
end

-- Reads a data file no matter how it is written: a plain `return { ... }`, or a file that builds its tables
-- with `local x = { ... }` / merge loops. Comments are stripped, then EVERY top-level { ... } table is parsed
-- and merged into one.
local function ParseData(src)
    local clean = src:gsub("%-%-[^\n]*", "")
    local merged, found = {}, false
    local pos = 1
    while true do
        local s = clean:find("{", pos, true)
        if not s then break end
        local ok, value, endPos = pcall(ParseLua, clean:sub(s))
        if not ok or type(value) ~= "table" then break end
        for k, v in pairs(value) do merged[k] = v end
        found = true
        pos = s + (endPos or 2) - 1
    end
    return found and merged or nil
end

local function Normalize(v)
    -- a move can keep its actions in an `actions = { ... }` list next to id / range
    if type(v) == "table" and type(v.actions) == "table" then
        local acts, r = Normalize(v.actions)
        return acts, tonumber(v.range or v.distance or v.dist) or r
    end

    local actions = {}
    local function add(kind, t, unparryable)
        if type(t) == "table" then
            for _, x in ipairs(t) do add(kind, x, unparryable) end
        elseif type(t) == "number" then
            local k = string.lower(tostring(kind))
            if unparryable and k ~= "dodge" then k = "unparryable" end
            -- crouch actions are no longer supported (there is no uncrouch step any more)
            if k ~= "crouch" then
                actions[#actions + 1] = {kind = k, t = t}
            end
        end
    end

    if type(v) == "number" then
        add("parry", v)
    elseif type(v) == "table" then
        if v.type or v.t then
            add(v.type or "parry", v.t, v.unparryable)
        else
            for _, item in ipairs(v) do
                if type(item) == "number" then
                    add("parry", item)
                elseif type(item) == "table" then
                    add(item.type or "parry", item.t, item.unparryable)
                end
            end
        end
    end
    -- optional base distance for this animation
    local range
    if type(v) == "table" then
        range = tonumber(v.range or v.distance or v.dist)
        if not range then
            for _, item in ipairs(v) do
                if type(item) == "table" then
                    local r = tonumber(item.range or item.distance or item.dist)
                    if r then range = r break end
                end
            end
        end
    end
    return #actions > 0 and actions or nil, range
end

-- Animation ids can be written as a number, "123" or "rbxassetid://123".
local function IdString(v)
    if type(v) == "number" then return string.format("%.0f", v) end
    return CleanId(v)
end

-- true for keys that are themselves an animation id: [123], ["123"], ["rbxassetid://123"]
local function IsIdKey(k)
    if type(k) == "number" then return true end
    if type(k) ~= "string" then return false end
    return k:match("^%s*%d+%s*$") ~= nil or k:match("^%s*rbxassetid://%d+%s*$") ~= nil
end

-- the animation id(s) a move table carries: id = 123 | id = "rbxassetid://123" | id = { 123, 456 }
local function MoveIds(v)
    local raw = v.id or v.ids or v.animationid or v.animation
    if raw == nil then return nil end
    local ids = {}
    if type(raw) == "table" then
        for _, x in ipairs(raw) do
            local s = IdString(x)
            if s then ids[#ids + 1] = s end
        end
    else
        local s = IdString(raw)
        if s then ids[1] = s end
    end
    return #ids > 0 and ids or nil
end

-- Walks the data file and collects { id, name, spec, range } for every animation. Understood layouts:
--   [123] = 0.4                                   (old: id as key)
--   ["rbxassetid://123"] = { type = "dodge", t = 0.4 }
--   Claws = { range = 15, M1 = { id = 123, type = "parry", t = 0.4 }, M2 = { id = 456, t = { 0.3, 0.6 } } }
--   ["Move Name"] = { id = 123, actions = { { type = "parry", t = 0.4 }, { type = "dodge", t = 0.8 } } }
-- A table that has an `id` is a move; a table without one is a group (any depth) whose own `range`
-- becomes the default for the moves inside it.
local function Flatten(tbl, path, defRange, out, cat)
    for key, value in pairs(tbl) do
        if type(value) == "number" and IsIdKey(key) then
            local id = IdString(key)
            out[#out + 1] = { id = id, name = id, spec = value, range = defRange, cat = cat or NO_CATEGORY }
        elseif type(value) == "table" then
            local label = (path ~= "" and (path .. " ") or "") .. tostring(key)
            local ids = MoveIds(value)
            if ids then
                for _, id in ipairs(ids) do
                    out[#out + 1] = { id = id, name = label, spec = value, range = defRange, cat = cat or NO_CATEGORY }
                end
            elseif IsIdKey(key) then
                local id = IdString(key)
                out[#out + 1] = { id = id, name = id, spec = value, range = defRange, cat = cat or NO_CATEGORY }
            else
                local before = #out
                local r = tonumber(value.range or value.distance or value.dist) or defRange
                Flatten(value, label, r, out, cat or tostring(key))
                if #out == before then
                    Log("Skipped '" .. label .. "' (no animation id found inside it)")
                end
            end
        end
    end
end

local RefreshCategoryOptions -- assigned once the Debug tab exists

local function LoadData()
    AnimDB = {}
    AnimMaxRange = 0
    AnimCategories = {}
    Status.loaded = 0

    local n = 0
    -- cache-buster so GitHub's raw CDN doesn't hand back a stale copy right after you push
    local src = HttpGet(ANIM_URL .. "?v=" .. tostring(os.time and os.time() or 0))
    local data
    if src then
        if type(loadstring) == "function" then
            local fn, compileErr = loadstring(src)
            if fn then
                local ok, res = pcall(fn)
                if ok and type(res) == "table" then data = res end
            else
                Log("loadstring could not compile the animation file (" .. tostring(compileErr) .. ")")
            end
        end
        if not data then
            local ok, res = pcall(ParseData, src)
            if ok and type(res) == "table" then
                data = res
            else
                Log("fallback parser failed: " .. tostring(res))
            end
        end
    end

    if data then
        local entries = {}
        Flatten(data, "", nil, entries)
        for _, e in ipairs(entries) do
            local actions, range = Normalize(e.spec)
            range = range or e.range
            if actions then
                AnimDB[e.id] = {name = e.name, actions = actions, range = range, cat = e.cat}
                if range and range > AnimMaxRange then AnimMaxRange = range end
                n = n + 1
            else
                Log("Skipped '" .. tostring(e.name) .. "' (no valid timing found)")
            end
        end
        Log("Loaded " .. n .. " animations")
    elseif src and not src:match("%S") then
        Log("Animation file downloaded but it is empty. If you just pushed it, GitHub may still be serving the old copy: wait a minute and press Reload Anim Data in the Debug tab.")
    else
        Log("Failed to load animation file: " .. ANIM_URL .. (src and (" (could not parse; starts with: " .. src:sub(1, 60) .. ")") or " (download failed)"))
    end

    Status.loaded = n

    -- category list (top-level groups of the data file) for the Debug tab's print dropdown
    local seenCat = {}
    for _, info in pairs(AnimDB) do
        if info.cat and not seenCat[info.cat] then
            seenCat[info.cat] = true
            AnimCategories[#AnimCategories + 1] = info.cat
        end
    end
    table.sort(AnimCategories, function(x, y) return string.lower(x) < string.lower(y) end)
    if RefreshCategoryOptions then pcall(RefreshCategoryOptions) end
end

-- IGNORED ANIMS
local IgnoredIds = {}

local function LoadIgnored()
    IgnoredIds = {}

    local src = HttpGet(IGNORE_URL)
    if not src then
        Log("Failed to download ignore list from " .. IGNORE_URL)
        return
    end

    for line in src:gmatch("[^\r\n]+") do
        line = line:gsub("%-%-.*$", "")
        for id in line:gmatch("%d+") do IgnoredIds[id] = true end
    end

    local n = 0
    for _ in pairs(IgnoredIds) do n = n + 1 end
    Status.ignored = n
    Log("Ignoring " .. n .. " animations")
end

-- WINDOW
Nexa:CreateWindow({
    Title = "D://Slayer",
    Subtitle = "Tungity Tungity Sahurity",
    GameName = GAME_NAME,
    Width = 860,
    Height = 610,
    Theme = "Obsidian",
    Background = "none",
    Opacity = 100,
    MenuKey = "p",
    Logo = LOGO_URL,
    BackgroundImage = BG_IMG,
    Splash = { Image = LOGO_URL },
    ShowLogo = LOGO_URL ~= nil,
    ShowGameName = true,
    IslandExpanded = true,
})

-- UI performance defaults (turn back on via the island icons / Settings tab if you want them)
do
    local S = Nexa.State
    S.Settings.KeybindOverlay = false
    S.Settings.PerformanceOverlay = false

    local settingsTab = Nexa:GetTab("Settings")
    if settingsTab then
        for _, row in ipairs(settingsTab.Rows or {}) do
            for _, ctrl in ipairs(row.Rows or {}) do
                if ctrl.Title == "Border animation" and ctrl.SetValue then ctrl:SetValue(false) end
            end
        end
    end
end

local mainTab       = Nexa:AddTab({ Title = "Auto Parry", Icon = "shield", Select = true })
local automationTab = Nexa:AddTab({ Title = "Automation", Icon = "zap" })
local visualsTab    = Nexa:AddTab({ Title = "Visuals", Icon = "eye" })
local miscTab       = Nexa:AddTab({ Title = "Misc", Icon = "layers" })
local qolTab        = Nexa:AddTab({ Title = "QOL", Icon = "zap" })
local trackerTab    = Nexa:AddTab({ Title = "Tracker", Icon = "crosshair" })
local whitelistTab  = Nexa:AddTab({ Title = "Whitelists", Icon = "users" })
local debugTab      = Nexa:AddTab({ Title = "Debug", Icon = "search" })

-- FRIEND EXCLUSIONS
local HttpService = game:GetService("HttpService")
local FRIENDS_FILE = "DemonSlayer_ExcludedFriends.json"
local IgnoredFriends = {}

local function LoadIgnoredFriends()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    local ok, raw = pcall(function()
        if isfile(FRIENDS_FILE) then return readfile(FRIENDS_FILE) end
    end)
    if not ok or type(raw) ~= "string" or raw == "" then return end
    local good, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if good and type(decoded) == "table" then
        IgnoredFriends = {}
        for _, name in ipairs(decoded) do
            if type(name) == "string" then IgnoredFriends[name] = true end
        end
    end
end

local function SaveIgnoredFriends()
    if type(writefile) ~= "function" then
        Nexa:Notify({ Title = "Friends", Content = "This executor does not support saving files.", Type = "warning", Duration = 3 })
        return
    end
    local names = {}
    for name in pairs(IgnoredFriends) do names[#names + 1] = name end
    table.sort(names)
    local ok = pcall(function() writefile(FRIENDS_FILE, HttpService:JSONEncode(names)) end)
    Nexa:Notify({ Title = "Friends", Content = ok and ("Saved " .. #names .. " excluded name(s).") or "Could not save friend list.", Type = ok and "success" or "error", Duration = 3 })
end

LoadIgnoredFriends()

-- lower-cased lookup; enemies carry a pre-lowered name (lname) so the scan never allocates strings
local FriendsLower = {}
local function RebuildFriendsLower()
    FriendsLower = {}
    for name in pairs(IgnoredFriends) do FriendsLower[string.lower(name)] = true end
end
RebuildFriendsLower()

-- WHITELISTS TAB: FRIENDS
do
local friendsSec = whitelistTab:AddSection("Friends", "Selected players will never be tracked by auto-parry.", { Column = "left" })
local friendsDropdown
local function GetPlayerNames()
    local found, names = {}, {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            found[player.Name] = true
        end
    end
    for name in pairs(IgnoredFriends) do found[name] = true end
    for name in pairs(found) do names[#names + 1] = name end
    table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
    return names
end
local function GetIgnoredFriendNames()
    local names = {}
    for name in pairs(IgnoredFriends) do names[#names + 1] = name end
    table.sort(names)
    return names
end
local function RefreshFriendDropdown()
    local options = GetPlayerNames()
    if #options == 0 then options = {"No other players"} end
    if friendsDropdown then
        friendsDropdown.Options = options
        friendsDropdown._listScroll = 0
        friendsDropdown._listScrollTo = 0
        local selected = {}
        for _, name in ipairs(GetIgnoredFriendNames()) do
            for _, option in ipairs(options) do
                if option == name then selected[#selected + 1] = name end
            end
        end
        pcall(function() friendsDropdown:SetValue(selected, true) end)
    end
end
friendsDropdown = friendsSec:AddDropdown({
    Title = "Excluded players",
    Description = "Multi-select names to ignore.",
    Options = (#GetPlayerNames() > 0 and GetPlayerNames() or {"No other players"}),
    Default = GetIgnoredFriendNames(),
    Multi = true,
    VisibleRows = 8,
    ConfigKey = "demonslayer.friends.excluded",
    Callback = function(value)
        if type(value) ~= "table" then return end
        IgnoredFriends = {}
        for _, name in ipairs(value) do
            if type(name) == "string" and name ~= "No other players" then
                IgnoredFriends[name] = true
            end
        end
        RebuildFriendsLower()
        SaveIgnoredFriends()
    end,
})
friendsSec:AddButton({
    Title = "",
    ButtonText = "Refresh player list",
    Expand = true,
    Callback = RefreshFriendDropdown,
})
friendsSec:AddButton({
    Title = "",
    ButtonText = "Save exclusions",
    Expand = true,
    Callback = SaveIgnoredFriends,
})

end

-- WHITELISTS TAB: FACTION
do
local factionSec = whitelistTab:AddSection("Faction", "Skip players on your own faction (Slayer / Demon).", { Column = "right" })
local yourFactionStatus = factionSec:AddStatus({ Title = "Your faction", Default = "-", Tone = "muted" })

local function ReadMyFaction()
    local lp = Players.LocalPlayer
    local alive = workspace:FindFirstChild("Alive")
    local me = (lp and alive and alive:FindFirstChild(lp.Name)) or (lp and lp.Character)
    return me and GetFaction(me) or nil
end

local function ShowMyFaction()
    local f = ReadMyFaction()
    pcall(function() yourFactionStatus:SetValue(f or "-", f and "accent" or "muted") end)
    return f
end

Reg("sb_parry_same_faction", factionSec:AddToggle({
    Title = "Parry Same Faction",
    Tooltip = "Off (default): players whose Faction attribute matches yours are ignored by auto parry. On: they are parried like anyone else.",
    Default = false,
    ConfigKey = "demonslayer.parry.sameFaction",
}))
factionSec:AddButton({
    Title = "",
    ButtonText = "Check my faction",
    Variant = "primary",
    Expand = true,
    Callback = function()
        local f = ShowMyFaction()
        Nexa:Notify({
            Title = "Faction",
            Content = f and ("You are: " .. f) or "No Faction attribute found on your character.",
            Type = f and "success" or "warning", Duration = 3,
        })
    end,
})
ShowMyFaction()
end

-- AUTO PARRY TAB
do
local parrySec = mainTab:AddSection("Auto Parry", "Targets and feint handling.", { Column = "left" })

local enabledToggle = Reg("sb_parry_on", parrySec:AddToggle({
    Title = "Enabled",
    Default = false,
    ConfigKey = "demonslayer.parry.enabled",
}))
enabledToggle:AddKeybind({
    Title = "Enable bind",
    Default = "none",
    Mode = "Toggle",
    ConfigKey = "demonslayer.parry.enabled.bind",
    OnPressed = function() enabledToggle:SetValue(not enabledToggle:GetValue()) end,
})
Reg("sb_parry_players", parrySec:AddToggle({
    Title = "Auto Parry Players",
    Default = true,
    ConfigKey = "demonslayer.parry.players",
}))
Reg("sb_parry_npcs", parrySec:AddToggle({
    Title = "Auto Parry NPCs",
    Default = true,
    ConfigKey = "demonslayer.parry.npcs",
}))
Reg("sb_parry_chance", parrySec:AddSlider({
    Title = "Parry Chance",
    Min = 1, Max = 100, Step = 1, Default = 100, Suffix = "%",
    ConfigKey = "demonslayer.parry.chance",
}))
do
    local generalToggle = Reg("sb_use_general_range", parrySec:AddToggle({
        Title = "Use General Range",
        Tooltip = "On: every animation uses the General Range slider. Off: each animation uses its own base distance from the data file (20 studs if it has none).",
        Default = true,
        ConfigKey = "demonslayer.parry.useGeneralRange",
    }))
    local rangeSlider = Reg("sb_range", parrySec:AddSlider({
        Title = "General Range",
        Tooltip = "Only react to animations from enemies within this many studs. Only used while Use General Range is on.",
        Min = 5, Max = 100, Step = 1, Default = 20, Suffix = " studs",
        ConfigKey = "demonslayer.parry.range",
    }))
    rangeSlider:SetEnabled(generalToggle.Value and true or false)
    generalToggle:OnChanged(function(v) rangeSlider:SetEnabled(v and true or false) end)
end

-- PING COMP (own section, directly under the main Auto Parry section)
local pingSec = mainTab:AddSection("Ping Compensation", "Fires actions earlier to cover your latency.", { Column = "left" })
do
    local autoPingToggle = Reg("sb_t_autoping", pingSec:AddToggle({
        Title = "Auto Ping Comp",
        Tooltip = "On: uses your live (smoothed) ping and fires the one-way trip (ping / 2) earlier, nothing under 25 ms. Off: uses the Ping Comp slider.",
        Default = true,
        ConfigKey = "demonslayer.timing.autoPing",
    }))
    local pingSlider = Reg("sb_t_ping", pingSec:AddSlider({
        Title = "Ping Comp",
        Tooltip = "Used when Auto Ping Comp is off: fires actions this many ms earlier. Timings are tuned for ~60 ping; auto-set from your ping on inject.",
        Min = -BASE_PING, Max = 300, Step = 1, Default = 0, Suffix = "ms",
        ConfigKey = "demonslayer.timing.ping",
    }))
    pingSlider:SetEnabled(not autoPingToggle.Value)
    autoPingToggle:OnChanged(function(v) pingSlider:SetEnabled(not v) end)
end

local feintSec = mainTab:AddSection("Feints", "Handling for canceled swings.", { Column = "right" })
Reg("sb_feint_detect", feintSec:AddToggle({
    Title = "Detect Feints",
    Tooltip = "Watches every nearby enemy for a feint: the \"FeintedAt\" attribute changing, or a sound named \"Feint\" appearing. Uses change / child-added events when the runtime supports them and falls back to polling (Feint Check Rate). A detected feint cancels only that enemy's swings that were already playing when it happened; swings that start afterwards are unaffected. A swing that stops early is still skipped.",
    Default = true,
    ConfigKey = "demonslayer.parry.feintDetect",
}))
Reg("sb_parry_feint_chance", feintSec:AddSlider({
    Title = "Parry Feint Chance",
    Tooltip = "Chance to still press the scheduled key after a feint is detected. At 0%, detected feints are skipped; at 100%, they are always acted on.",
    Min = 0, Max = 100, Step = 1, Default = 0, Suffix = "%",
    ConfigKey = "demonslayer.parry.feintChance",
}))

Reg("sb_feint_rate", feintSec:AddSlider({
    Title = "Feint Check Rate",
    Tooltip = "Fallback poll for enemies that are mid-swing, in ms between checks (0 = every frame). The event listeners do not depend on it. It only watches for feints and never delays a parry.",
    Min = 0, Max = 100, Step = 1, Default = 5, Suffix = "ms",
    ConfigKey = "demonslayer.parry.feintCheckRate",
}))

-- DODGING (own section)
local dodgeSec = mainTab:AddSection("Dodging", "Press Q (dodge) instead of F (parry), with a cooldown between dodges.", { Column = "right" })
do
    local prioToggle = Reg("sb_dodge_priority", dodgeSec:AddToggle({
        Title = "Prioritize Dodge",
        Tooltip = "Every parry action presses Q (dodge) instead of F. Actions marked as dodge in the data file always press Q.",
        Default = false,
        ConfigKey = "demonslayer.dodge.priority",
    }))
    local chanceSlider = Reg("sb_dodge_chance", dodgeSec:AddSlider({
        Title = "Randomize Dodge Chance",
        Tooltip = "Chance for each parry action to press Q (dodge) instead of F. 0 = never. Ignored while Prioritize Dodge is on.",
        Min = 0, Max = 100, Step = 1, Default = 0, Suffix = "%",
        ConfigKey = "demonslayer.dodge.chance",
    }))
    Reg("sb_dodge_cooldown", dodgeSec:AddSlider({
        Title = "Dodge Cooldown",
        Tooltip = "After a dodge (Q) goes out, any dodge inside this window parries (F) instead. 0 = no cooldown.",
        Min = 0, Max = 5000, Step = 50, Default = 1500, Suffix = "ms",
        ConfigKey = "demonslayer.dodge.cooldown",
    }))
    chanceSlider:SetEnabled(not prioToggle.Value)
    prioToggle:OnChanged(function(v) chanceSlider:SetEnabled(not v) end)
end

end

-- AUTOMATION TAB (placeholders)
do
local generalSec = automationTab:AddSection("General", "Quality-of-life automation.", { Column = "left" })
Reg("auto_log", generalSec:AddToggle({
    Title = "Auto Log (STR)",
    Tooltip = "Teleports to the log spot, presses E, teleports to the second spot, and repeats (0.5s waits).",
    Default = false,
    ConfigKey = "demonslayer.automation.autoLog",
}))
Reg("auto_mediate", generalSec:AddToggle({
    Title = "Auto Mediate (FOCUS)",
    Tooltip = "Needs more than 25 yen. Teleports to a Blood Focus Arena mat, presses E, confirms, then keeps the mouse on the orb closest to the top-left corner.",
    Default = false,
    ConfigKey = "demonslayer.automation.autoMediate",
}))
local moreSec = automationTab:AddSection("More", "Coming later.", { Column = "right" })
moreSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
end

-- VISUALS TAB (placeholders + ESP options)
do
local espWorldSec = visualsTab:AddSection("World", "World ESP.", { Column = "left" })
espWorldSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
local espLootSec = visualsTab:AddSection("Loot", "Pickups and drops.", { Column = "left" })
espLootSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
local espMiscSec = visualsTab:AddSection("Misc", "Other ESP.", { Column = "left" })
espMiscSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
local espEntitiesSec = visualsTab:AddSection("Entities", "Things that move around.", { Column = "right" })
espEntitiesSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })

local espOptionsSec = visualsTab:AddSection("Options", "How the ESP is drawn.", { Column = "right" })
Reg("esp_enabled", espOptionsSec:AddToggle({
    Title = "Enabled",
    Tooltip = "Master switch for every ESP.",
    Default = true,
    ConfigKey = "demonslayer.visuals.espEnabled",
}))
Reg("esp_distance", espOptionsSec:AddToggle({
    Title = "Distance",
    Tooltip = "Shows the distance in studs under the box.",
    Default = true,
    ConfigKey = "demonslayer.visuals.espDistance",
}))
Reg("esp_box", espOptionsSec:AddToggle({
    Title = "Box",
    Tooltip = "Draws a box around the target.",
    Default = true,
    ConfigKey = "demonslayer.visuals.espBox",
}))
Reg("esp_name", espOptionsSec:AddToggle({
    Title = "Name",
    Tooltip = "Shows the name above the box.",
    Default = true,
    ConfigKey = "demonslayer.visuals.espName",
}))
local espHealthToggle = Reg("esp_health", espOptionsSec:AddToggle({
    Title = "Health",
    Tooltip = "Master switch for health display. The three options below only work while this is on.",
    Default = true,
    ConfigKey = "demonslayer.visuals.espHealth",
}))
local espHealthSubs = {
    Reg("esp_health_bar", espOptionsSec:AddToggle({
        Title = "Bar",
        Tooltip = "Health bar on the left of the box.",
        Default = true,
        ConfigKey = "demonslayer.visuals.espHealthBar",
    })),
    Reg("esp_health_text", espOptionsSec:AddToggle({
        Title = "Text",
        Tooltip = "Shows the health in the label: name - [HP].",
        Default = false,
        ConfigKey = "demonslayer.visuals.espHealthText",
    })),
    Reg("esp_health_color", espOptionsSec:AddToggle({
        Title = "Based on HP",
        Tooltip = "Colours the health bar and text from green to yellow to red as health drops. Off = plain green bar, text in the ESP colour.",
        Default = true,
        ConfigKey = "demonslayer.visuals.espHealthColor",
    })),
}
do
    local function applyHealthSubs(on)
        for _, c in ipairs(espHealthSubs) do pcall(function() c:SetEnabled(on and true or false) end) end
    end
    applyHealthSubs(espHealthToggle:GetValue())
    espHealthToggle:OnChanged(applyHealthSubs)
end
Reg("esp_range", espOptionsSec:AddSlider({
    Title = "Render Distance",
    Tooltip = "Targets further than this are not drawn. 0 draws everything.",
    Min = 0, Max = 1000, Step = 10, Default = 500, Suffix = " studs",
    ConfigKey = "demonslayer.visuals.espRange",
}))
end

-- MISC TAB (placeholders)
do
local miscGeneralSec = miscTab:AddSection("Removals", "Strip effects and obstacles out of the world.", { Column = "left" })
miscGeneralSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
local miscMoreSec = miscTab:AddSection("Other", "Coming later.", { Column = "right" })
miscMoreSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
end

-- QOL TAB
do
local qolStatSec = qolTab:AddSection("Stat Farming", "Coming later.", { Column = "left" })
qolStatSec:AddLabel({ Title = "Placeholder", Description = "Nothing here yet." })
local qolHelpSec = qolTab:AddSection("Quality of Life", "Small helpers.", { Column = "right" })
Reg("spam_e", qolHelpSec:AddToggle({
    Title = "Spam E",
    Tooltip = "Taps E over and over (about 15 times a second). Pauses while the Roblox chat box is focused.",
    Default = false,
    ConfigKey = "demonslayer.qol.spamE",
}))
end

-- CONFIG AUTOSAVE / AUTOLOAD
do
    local CONFIG_FILE = "DemonSlayer_Config.json"
    local SKIP = { sb_t_ping = true, print_parries = true, print_feints = true, debug_hits = true, auto_log = true, auto_mediate = true }

    if type(readfile) == "function" and type(isfile) == "function" then
        local ok, raw = pcall(function()
            if isfile(CONFIG_FILE) then return readfile(CONFIG_FILE) end
        end)
        if ok and type(raw) == "string" and raw ~= "" then
            local good, saved = pcall(function() return HttpService:JSONDecode(raw) end)
            if good and type(saved) == "table" then
                for flag, ctrl in pairs(Controls) do
                    if not SKIP[flag] and saved[flag] ~= nil then
                        if ctrl.Kind == "ColorPicker" then
                            local hex = tostring(saved[flag]):gsub("#", "")
                            if #hex == 6 and hex:match("^%x+$") then
                                pcall(function()
                                    ctrl:SetValue(Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)))
                                end)
                            end
                        else
                            pcall(function() ctrl:SetValue(saved[flag]) end)
                        end
                    end
                end
            end
        end
    end

    if type(writefile) == "function" then
        -- event driven: nothing is polled or compared, we only write when a control actually changed
        task.spawn(function()
            ConfigDirty = false
            while Nexa:IsAlive() do
                task.wait(1)
                if ConfigDirty then
                    ConfigDirty = false
                    local snap = {}
                    for flag, ctrl in pairs(Controls) do
                        if not SKIP[flag] then
                            local v = ctrl.Value
                            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                                snap[flag] = v
                            elseif ctrl.Kind == "ColorPicker" and v then
                                local okc, hex = pcall(string.format, "#%02X%02X%02X", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
                                if okc then snap[flag] = hex end
                            end
                        end
                    end
                    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(snap)) end)
                end
            end
        end)
    end
end

-- TRACKER TAB
local Tracked = {}
local TrackedCount = 0
local Hist, HistDirty = {}, true
local HIST_MAX = 50
local NpcMap = {}
local FallbackMap = {}

local function GetTargetFromPath(path)
    local function walk(p)
        local current = workspace
        for part in string.gmatch(p, "[^/]+") do
            current = current:FindFirstChild(part)
            if not current then return nil end
        end
        return current
    end
    return walk(path) or walk("Alive/" .. path)
end

local function FindLiveByName(name)
    local live = workspace:FindFirstChild("Alive")
    if not live then return nil end
    for _, model in ipairs(live:GetChildren()) do
        if CleanName(model.Name) == name then return model end
    end
    return nil
end

local function FindOwnModel()
    local lp = Players.LocalPlayer
    if not lp then return nil end
    local ch = lp.Character
    if ch then return ch end
    local ok, list = pcall(function() return workspace:GetDescendants() end)
    if ok and type(list) == "table" then
        for _, v in ipairs(list) do
            if v.Name == lp.Name and v:FindFirstChild("Humanoid") then return v end
        end
    end
    return nil
end

-- Now Playing list
local playingSec = trackerTab:AddSection("Now Playing", "Animations seen on tracked targets (ignored ones hidden).", { Column = "left" })
local emptyLabel = playingSec:AddLabel({ Title = "Nothing yet", Description = "Pick a target and press Start Tracking." })
local histLabels = {}
for i = 1, HIST_SLOTS do
    local l = playingSec:AddLabel({ Title = "", Description = "" })
    l:SetVisible(false)
    histLabels[i] = l
end

local function RefreshHistLabels()
    HistDirty = false
    emptyLabel:SetVisible(#Hist == 0)
    for i = 1, HIST_SLOTS do
        local l, e = histLabels[i], Hist[i]
        if e then
            l:SetTitle(AnimLabel(e.id))
            l:SetDescription(string.format("%s  x%d  %s", e.target, e.count, AnimDB[e.id] and "(in data)" or "(new)"))
            l:SetVisible(true)
        else
            l:SetVisible(false)
        end
    end
end

local function AddHistory(id, targetName)
    for i, e in ipairs(Hist) do
        if e.id == id then
            e.count = e.count + 1
            e.target = targetName
            table.remove(Hist, i)
            table.insert(Hist, 1, e)
            HistDirty = true
            return
        end
    end
    table.insert(Hist, 1, {id = id, count = 1, target = targetName})
    if #Hist > HIST_MAX then table.remove(Hist) end
    HistDirty = true
end

-- Target selection
local trackSec = trackerTab:AddSection("Track Target", "Who to watch.", { Column = "right" })

local function SetOptions(dd, names)
    if #names == 0 then names = {"None"} end
    local keep = dd.Value
    dd.Options = names
    dd._listScroll = 0
    dd._listScrollTo = 0
    local pick = names[1]
    for _, n in ipairs(names) do if n == keep then pick = n break end end
    dd:SetValue(pick, true)
end

local targetType, playerDD, npcDD, pathBox, fallbackDD, folderStatus
local playerPrevBtn, playerNextBtn, npcPrevBtn, npcNextBtn

local function RefreshLists()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and not IgnoredFriends[p.Name] then
            names[#names + 1] = p.Name
        end
    end
    table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
    SetOptions(playerDD, names)

    NpcMap = {}
    local npcNames = {}
    local live = workspace:FindFirstChild("Alive")
    if live then
        for _, model in ipairs(live:GetChildren()) do
            local n = model.Name
            if not Players:FindFirstChild(CleanName(n)) and model:FindFirstChild("Humanoid") then
                local disp, c = n, 1
                while NpcMap[disp] do c = c + 1 disp = n .. " (" .. c .. ")" end
                NpcMap[disp] = model
                npcNames[#npcNames + 1] = disp
            end
        end
    end
    table.sort(npcNames, function(a, b) return string.lower(a) < string.lower(b) end)
    SetOptions(npcDD, npcNames)

    FallbackMap = {}
    local fbNames = {}
    local own = FindOwnModel()
    local folder = own and own.Parent
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model:FindFirstChild("Humanoid") then
                local n = CleanName(model.Name)
                local disp, c = n, 1
                while FallbackMap[disp] do c = c + 1 disp = n .. " (" .. c .. ")" end
                FallbackMap[disp] = model
                fbNames[#fbNames + 1] = disp
            end
        end
    end
    table.sort(fbNames, function(a, b) return string.lower(a) < string.lower(b) end)
    SetOptions(fallbackDD, fbNames)
    pcall(function() folderStatus:SetValue(folder and tostring(folder.Name) or "-", folder and "accent" or "muted") end)
end

local function UpdateTargetVisibility(kind)
    playerDD:SetVisible(kind == "Player")
    npcDD:SetVisible(kind == "NPC")
    fallbackDD:SetVisible(kind == "Fallback")
    pcall(function() folderStatus:SetVisible(kind == "Fallback") end)
    if pathBox then pathBox:SetVisible(kind == "NPC") end
    for _, b in ipairs({ playerPrevBtn, playerNextBtn }) do pcall(function() b:SetVisible(kind == "Player") end) end
    for _, b in ipairs({ npcPrevBtn, npcNextBtn }) do pcall(function() b:SetVisible(kind == "NPC") end) end
end

targetType = trackSec:AddDropdown({
    Title = "Target Type",
    Options = { "LocalPlayer", "Player", "NPC", "Fallback" },
    Default = "LocalPlayer",
    ConfigKey = "demonslayer.tracker.type",
    Callback = function(v)
        UpdateTargetVisibility(v)
        if v ~= "LocalPlayer" then RefreshLists() end
    end,
})
playerDD = trackSec:AddDropdown({ Title = "Player List", Options = { "None" }, Default = "None", VisibleRows = 8 })
npcDD    = trackSec:AddDropdown({ Title = "NPC List", Options = { "None" }, Default = "None", VisibleRows = 8 })
fallbackDD = trackSec:AddDropdown({ Title = "Fallback List", Options = { "None" }, Default = "None", VisibleRows = 8 })
folderStatus = trackSec:AddStatus({ Title = "Folder", Default = "-", Tone = "muted" })
-- Prev / Next buttons walk the player (or NPC) list one entry at a time, for when the list can't be scrolled
local function StepDropdown(dd, dir)
    local opts = dd.Options or {}
    local n = #opts
    if n == 0 or (n == 1 and (opts[1] == "None" or opts[1] == "No other players")) then
        Nexa:Notify({ Title = "Tracker", Content = "Nothing to select yet. Try Refresh.", Type = "warning", Duration = 2 })
        return
    end
    local cur = 0
    for i, o in ipairs(opts) do
        if o == dd.Value then cur = i break end
    end
    local nxt = ((cur - 1 + dir) % n) + 1
    dd:SetValue(opts[nxt])
    -- scroll the open list so the new pick is in view (8 rows are visible)
    dd._listScrollTo = math.max(0, math.min(nxt - 1, math.max(0, n - 8)))
    dd._listScroll = dd._listScrollTo
end

playerPrevBtn = trackSec:AddButton({ Title = "", ButtonText = "Previous player", Expand = true, Callback = function() StepDropdown(playerDD, -1) end })
playerNextBtn = trackSec:AddButton({ Title = "", ButtonText = "Next player", Expand = true, Callback = function() StepDropdown(playerDD, 1) end })
npcPrevBtn = trackSec:AddButton({ Title = "", ButtonText = "Previous NPC", Expand = true, Callback = function() StepDropdown(npcDD, -1) end })
npcNextBtn = trackSec:AddButton({ Title = "", ButtonText = "Next NPC", Expand = true, Callback = function() StepDropdown(npcDD, 1) end })

pathBox  = trackSec.AddTextbox and trackSec:AddTextbox({
    Title = "NPC Path",
    Placeholder = "Alive/NpcName (optional)",
    Default = "",
})
UpdateTargetVisibility("LocalPlayer")

local trackingStatus = trackSec:AddStatus({ Title = "Tracking", Default = "None", Tone = "muted" })

local function UpdateTrackingStatus()
    if TrackedCount == 0 then
        trackingStatus:SetValue("None", "muted")
    else
        trackingStatus:SetValue(TrackedCount .. " target" .. (TrackedCount > 1 and "s" or ""), "success")
    end
end

local function ResolveTarget()
    local kind = targetType:GetValue()
    if kind == "LocalPlayer" then
        local lp = Players.LocalPlayer
        return FindLiveByName(lp.Name), lp.Name
    elseif kind == "Player" then
        local n = playerDD:GetValue()
        if IgnoredFriends[n] then return nil, n .. " (excluded)" end
        return FindLiveByName(n), n
    elseif kind == "Fallback" then
        local disp = fallbackDD:GetValue()
        return FallbackMap[disp], disp
    end

    local path = pathBox and tostring(pathBox:GetValue() or "") or ""
    if path ~= "" then
        local model = GetTargetFromPath(path)
        return model, path:match("([^/]+)$") or path
    end
    local disp = npcDD:GetValue()
    return NpcMap[disp], disp
end

local function StartTracking()
    if targetType:GetValue() ~= "LocalPlayer" then RefreshLists() end
    local model, label = ResolveTarget()
    if not model then
        Nexa:Notify({ Title = "Tracker", Content = "Target not found: " .. tostring(label), Type = "warning", Duration = 3 })
        return
    end
    local addr = model.Address
    if not Tracked[addr] then
        Tracked[addr] = { model = model, animator = GetAnimatorAddr(model), name = label, seen = {} }
        TrackedCount = TrackedCount + 1
    end
    UpdateTrackingStatus()
    Nexa:Notify({ Title = "Tracker", Content = "Tracking " .. tostring(label), Type = "success", Duration = 2 })
end

local function StopTracking()
    Tracked, TrackedCount = {}, 0
    UpdateTrackingStatus()
end

trackSec:AddButton({ Title = "", ButtonText = "Start Tracking", Variant = "primary", Expand = true, Callback = StartTracking })
trackSec:AddButton({ Title = "", ButtonText = "Stop All Tracking", Variant = "danger", Expand = true, Callback = StopTracking })

do
local ctrlSec = trackerTab:AddSection("Controls", "Tracker history controls.", { Column = "left" })
ctrlSec:AddButton({
    Title = "",
    ButtonText = "Refresh / Clear labels",
    Expand = true,
    Callback = function()
        Hist, HistDirty = {}, true
        for _, t in pairs(Tracked) do t.seen = {} end
        if targetType:GetValue() ~= "LocalPlayer" then RefreshLists() end
    end,
})
end

RefreshLists()

local TRACKER_INTERVAL = 0.05
local nextTrackerAt = 0
local function GetParent(m) return m.Parent end

local function TrackerStep()
    if TrackedCount == 0 then return end

    for addr, tgt in pairs(Tracked) do
        local okP, parent = pcall(GetParent, tgt.model)
        if not okP or not parent then
            Tracked[addr] = nil
            TrackedCount = TrackedCount - 1
            UpdateTrackingStatus()
        else
            if tgt.stale or not tgt.animator then
                tgt.animator = GetAnimatorAddr(tgt.model)
                tgt.stale = false
            end

            local seenNow = {}
            for _, anim in ipairs(GetPlayingAnims(tgt)) do
                seenNow[anim.track] = true
                if not tgt.seen[anim.track] then
                    tgt.seen[anim.track] = true
                    if not IgnoredIds[anim.id] then
                        AddHistory(anim.id, tgt.name)
                        Log(string.format("Track: %s | %s | %.2fs in | %s",
                            DisplayName(tgt.name), AnimNameId(anim.id), anim.elapsed or 0, AnimDB[anim.id] and "in data" or "new"))
                    end
                end
            end
            for k in pairs(tgt.seen) do
                if not seenNow[k] then tgt.seen[k] = nil end
            end
        end
    end
end

-- DEBUG TAB
-- Left column: Data (reload + console dumps), Logging (console output toggles), Tools (quick checks / tests).
-- Right column: Status (live info), Script (unload).
local dataSec  = debugTab:AddSection("Data", "Animation data and ignore list from GitHub, and console dumps.", { Column = "left" })
local logSec   = debugTab:AddSection("Logging", "Console output while auto parry runs.", { Column = "left" })
local toolsSec = debugTab:AddSection("Tools", "Quick checks and tests.", { Column = "left" })
dataSec:AddButton({ Title = "Reload Anim Data", ButtonText = "Reload", Callback = function() LoadData() end })
dataSec:AddButton({ Title = "Reload Ignored Anims", ButtonText = "Reload", Callback = function() LoadIgnored() end })
-- Prints the animations of one category (a top-level group of the data file, e.g. Katana), or all of them.
local function PrintAnimations(category)
    local ids = {}
    for id, info in pairs(AnimDB) do
        if not category or info.cat == category then ids[#ids + 1] = id end
    end
    -- natural sort on the name so M2 comes before M10
    local function sortKey(id)
        local name = AnimDB[id].name or id
        return (string.lower(name):gsub("%d+", function(d) return string.format("%08d", tonumber(d)) end))
    end
    table.sort(ids, function(a, b)
        local ka, kb = sortKey(a), sortKey(b)
        if ka ~= kb then return ka < kb end
        return a < b
    end)

    print(string.format("%s ===== %s (%d animations) =====", LOG_TAG, category or "All animations", #ids))
    for _, id in ipairs(ids) do
        local info = AnimDB[id]
        local parts = {}
        for _, action in ipairs(info.actions) do
            parts[#parts + 1] = string.format("%s@%.3f", action.kind, action.t)
        end
        print(string.format("%s %s | %s = %s%s", LOG_TAG, info.name or "Unknown", id,
            table.concat(parts, ", "), info.range and (" | range " .. info.range) or ""))
    end
    print(LOG_TAG .. " ===== end =====")

    Nexa:Notify({
        Title = "Anim Table",
        Content = "Printed " .. #ids .. " animation" .. (#ids == 1 and "" or "s") .. " to the console.",
        Type = "success", Duration = 3,
    })
end

CategoryDD = dataSec:AddDropdown({
    Title = "Weapon / Category",
    Tooltip = "The groups in the animation file (Claws, Katana, ...). Pick one, then press Print Category.",
    Options = { "None" },
    Default = "None",
    VisibleRows = 8,
})

RefreshCategoryOptions = function()
    if not CategoryDD then return end
    local names = #AnimCategories > 0 and AnimCategories or { "None" }
    local keep = CategoryDD.Value
    CategoryDD.Options = names
    CategoryDD._listScroll = 0
    CategoryDD._listScrollTo = 0
    local pick = names[1]
    for _, n in ipairs(names) do if n == keep then pick = n break end end
    CategoryDD:SetValue(pick, true)
end
RefreshCategoryOptions()

dataSec:AddButton({
    Title = "Print Category",
    ButtonText = "Print",
    Tooltip = "Prints every animation under the selected weapon / category",
    Callback = function()
        local cat = CategoryDD:GetValue()
        if not cat or cat == "None" or #AnimCategories == 0 then
            Nexa:Notify({ Title = "Anim Table", Content = "No category loaded yet.", Type = "warning", Duration = 3 })
            return
        end
        PrintAnimations(cat)
    end,
})
dataSec:AddButton({
    Title = "Print All Animations",
    ButtonText = "Print All",
    Tooltip = "Prints every animation loaded from GitHub (name, id and its actions) to the console",
    Callback = function() PrintAnimations(nil) end,
})

local St = {}
do
local statSec = debugTab:AddSection("Status", "Live script info.", { Column = "right" })
St.Loaded = statSec:AddStatus({ Title = "Loaded anims",  Default = "0", Tone = "accent" })
St.Ignored = statSec:AddStatus({ Title = "Ignored anims", Default = "0", Tone = "muted" })
St.Track = statSec:AddStatus({ Title = "Tracking",      Default = "0", Tone = "success" })
St.Last = statSec:AddStatus({ Title = "Last",          Default = "none", Tone = "muted" })
St.Dist = statSec:AddStatus({ Title = "Distance",      Default = "0.0", Tone = "muted" })
St.Loop = statSec:AddStatus({ Title = "Loop / Scan",   Default = "0 / 0 ms", Tone = "muted" })
St.Ping = statSec:AddStatus({ Title = "Ping / Comp",   Default = "-", Tone = "muted" })
St.Feint = statSec:AddStatus({ Title = "Feint monitor", Default = "-", Tone = "muted" })
end
local scriptSec = debugTab:AddSection("Script", "Unload the script and give input back to the game.", { Column = "right" })

local function ApplyPing(samples, silent)
    samples = samples or 1
    local sum, n = 0, 0
    for i = 1, samples do
        local p = GetPingValue()
        if p then sum = sum + p n = n + 1 end
        if i < samples then task.wait(0.25) end
    end

    if n == 0 then
        if not silent then
            Nexa:Notify({ Title = "Ping", Content = "Could not read your ping.", Type = "warning", Duration = 3 })
        end
        return nil
    end

    local ping = sum / n
    local comp = PingToComp(ping)
    Status.ping = ping
    Status.comp = comp

    local ctrl = Controls.sb_t_ping
    if ctrl then pcall(function() ctrl:SetValue(comp) end) end

    Log(string.format("Ping %.0f ms -> Ping Comp %d ms", ping, comp))
    Nexa:Notify({
        Title = "Ping",
        Content = string.format("%.0f ms - Ping Comp set to %d ms", ping, comp),
        Type = "success",
        Duration = 3,
    })
    return ping
end

toolsSec:AddButton({
    Title = "Print Ping",
    ButtonText = "Print Ping",
    Callback = function()
        local myPing = GetPingValue()
        if not myPing then
            Log("Ping read failed. Every method tried:\n" .. LOG_TAG .. "   " .. tostring(PingError))
            Nexa:Notify({ Title = "Ping", Content = "Could not read your ping (see console).", Type = "warning", Duration = 4 })
            return
        end

        local comp = GetPingComp()
        Log(string.format("Ping: %.0f ms | Comp: %.0f ms | via %s", myPing, comp, PingMethod))
        Nexa:Notify({
            Title = "Ping",
            Content = string.format("%.0f ms (comp %.0f ms) via %s", myPing, comp, PingMethod),
            Type = "success",
            Duration = 3,
        })
    end,
})

Reg("print_parries", logSec:AddToggle({
    Title = "Print Parries",
    Tooltip = "Prints every action the auto-parry fires (kind, key, enemy, animation id)",
    Default = false,
}))

Reg("print_feints", logSec:AddToggle({
    Title = "Print Feints",
    Tooltip = "Prints every feint the monitor detects (enemy, what signalled it, how many queued actions it cancelled) and every action skipped because of a feint or an animation that stopped early, including whether the Parry Feint Chance made it act anyway.",
    Default = false,
}))

Reg("debug_hits", logSec:AddToggle({
    Title = "Log Hits",
    Tooltip = "When your health drops while an enemy animation is playing, prints who hit you, which animation, and how many ms after it started. Also shows whether an action was fired and how long before the hit. Needs Auto Parry enabled.",
    Default = false,
}))

local lastStatusUpdate = 0
local function UpdateStatusUI(now)
    if now - lastStatusUpdate < 0.25 then return end
    lastStatusUpdate = now

    if HistDirty then RefreshHistLabels() end

    -- the status badges are only on screen in the Debug tab, so don't touch them otherwise
    if Nexa.State.Tabs[Nexa.State.ActiveIndex] ~= debugTab then return end

    St.Loaded:SetValue(tostring(Status.loaded))
    St.Ignored:SetValue(tostring(Status.ignored))
    St.Track:SetValue(tostring(Status.tracked))
    St.Last:SetValue(tostring(Status.last))
    St.Dist:SetValue(string.format("%.1f", Status.lastDist))
    St.Loop:SetValue(string.format("%.0f / %.0f ms", Status.loopMs, Status.scanMs))
    St.Feint:SetValue(tostring(Status.feint or "-"))
    local livePing = GetPingValue()
    if livePing then
        Status.ping = livePing
        if Controls.sb_t_autoping.Value then
            UpdateAutoPing(now)
            St.Ping:SetValue(string.format("%.0f / %.0f ms (auto)", AutoPing.smooth or livePing, AutoPing.comp), "accent")
        else
            St.Ping:SetValue(string.format("%.0f / %d ms", livePing, Controls.sb_t_ping.Value or 0), "accent")
        end
    else
        St.Ping:SetValue("unavailable", "muted")
    end
end

-- LOGIC
local cOn      = Controls.sb_parry_on
local cPlayers = Controls.sb_parry_players
local cNpcs    = Controls.sb_parry_npcs
local cRange   = Controls.sb_range
local cGeneral = Controls.sb_use_general_range
local cChance  = Controls.sb_parry_chance
local cSameFaction = Controls.sb_parry_same_faction

-- HIT LOG (Debug tab, "Log Hits"): when an animation from an enemy is first seen, remember its start time and
-- your health. If your health later drops below that value while the animation is still going (plus a short
-- tail), it logs how many ms after the animation started you got hit, and whether/when an action was fired.
-- Needs Auto Parry enabled, since that is what scans enemy animations.
local HitWatch = { list = {} }

local function LocalHealth()
    local lp = Players.LocalPlayer
    local alive = workspace:FindFirstChild("Alive")
    local model = alive and lp and alive:FindFirstChild(lp.Name)
    local hum = model and model:FindFirstChild("Humanoid")
    if not hum then return nil end
    local ok, hp = pcall(function() return hum.Health end)
    if ok and type(hp) == "number" and hp == hp then return hp end
    return nil
end

function HitWatch.Start(akey, enemy, info, id, dist, elapsed, scheduled)
    if not Get("debug_hits") then return end
    local hp = LocalHealth()
    if not hp then return end
    local lastT = 0
    for _, a in ipairs(info.actions) do
        if a.t > lastT then lastT = a.t end
    end
    local startAt = os.clock() - (elapsed or 0)
    HitWatch.list[akey] = {
        startAt = startAt, hp0 = hp, enemy = DisplayName(enemy.name), id = id,
        dist = dist, scheduled = scheduled,
        expires = startAt + math.max(lastT + 0.75, 1.0),
    }
end

function HitWatch.Fired(akey, keyName)
    local w = HitWatch.list[akey]
    if w and not w.firedAt then
        w.firedAt, w.firedKey = os.clock(), keyName
    end
end

function HitWatch.Step(now)
    if next(HitWatch.list) == nil then return end
    local hp = LocalHealth()
    for akey, w in pairs(HitWatch.list) do
        if now > w.expires then
            HitWatch.list[akey] = nil
        elseif hp and not w.hit and hp < w.hp0 then
            w.hit = true
            local fired
            if w.firedAt then
                fired = string.format("%s fired %.0fms before the hit", w.firedKey, (now - w.firedAt) * 1000)
            elseif w.scheduled then
                fired = "nothing fired yet"
            else
                fired = "not scheduled (out of range / chance)"
            end
            Log(string.format("HIT by %s | %s | -%.0f HP, %.0fms after the animation started | %s | %.1f studs away",
                w.enemy, AnimNameId(w.id), w.hp0 - hp, (now - w.startAt) * 1000, fired, w.dist or 0))
        end
    end
end

local function ActionKey(kind, hold)
    if kind == "jump" then
        return KEY_JUMP, hold
    elseif kind == "dodge" or kind == "unparryable" then
        return KEY_DODGE, hold
    end
    return KEY_PARRY, hold
end

local function KeyName(vk)
    return vk == KEY_PARRY and "F" or vk == KEY_DODGE and "Q" or vk == KEY_JUMP and "Space" or "?"
end

-- Combat state kept in one table (the script is close to Lua's limit of local variables):
--   lastDodge : os.clock() of the last dodge (Q) that went out, for the Dodge Cooldown
--   Feint     : the feint monitor (built below)
local Combat = { lastDodge = -math.huge }

--------------------------------------------------------------------------------------------------
-- FEINT MONITOR
--
-- Completely separate from the parry timing code. It watches enemies, keeps independent per-enemy state
-- and publishes "this enemy feinted at time T" events. The action queue only READS that state (plain
-- table lookups, no Instance access) to decide whether a pending action should be skipped.
--
-- Signals used:
--   * the "FeintedAt" attribute changing (on the character model and on the Player object)
--   * a Sound named "Feint" appearing on the enemy (or being played again)
-- Detection paths:
--   * events: GetAttributeChangedSignal / ChildAdded listeners, connected when an enemy is registered
--     and disconnected when it goes away. Each hook is validated with pcall; if Matcha does not support
--     a signal, that hook is simply skipped (Feint.Caps shows which ones work).
--   * polling fallback: a cheap read of the attributes + the known sound spots, only for enemies that are
--     mid-swing (a rare descendant scan discovers unknown spots). Events and polls share the same
--     dedup state, so whichever sees a feint first publishes it and the other is ignored.
-- Per-enemy state: sequence number, ring of recent events { seq, at, via }, seen sounds, attribute values.
--
-- Cancellation rule (Feint.Affects): an event cancels a queued action when
--   event.at >= action.startAt - SLACK
-- i.e. the swing was already playing when the feint happened. Swings that start after the event are never
-- touched, and an old event never cancels a later swing. A swing that merely stops early (no signal) is
-- still caught by the existing IsAnimAlive check in FireDue.
--------------------------------------------------------------------------------------------------
do
local Feint = {
    States    = {},      -- [enemy key] = per-enemy state
    Count     = 0,
    Listeners = {},      -- function(state, event): called the moment a feint is published
    SOUND     = "Feint",
    SLACK     = 0.02,    -- an event up to 20 ms before the swing's start still counts as "during" it
    MERGE     = 0.05,    -- attribute + sound of the same feint inside this window are one event
    Caps      = { attr = nil, child = nil },   -- nil = untested, true / false once known
    Tries     = { attr = 0, child = 0 },
    Stats     = { signals = 0, byEvent = 0, byPoll = 0 },
    -- spots a Feint sound is looked for on every poll, as names from the enemy model down to the sound's parent
    Paths     = { { "HumanoidRootPart" }, {} },
    PathSet   = { ["HumanoidRootPart"] = true, [""] = true },
}
Combat.Feint = Feint

-- plain helpers (so pcall does not allocate a closure per call)
function Feint.NameOf(i) return i.Name end
function Feint.AddrOf(i) return i.Address end
function Feint.ParentOf(i) return i.Parent end
function Feint.ChildOf(i, n) return i:FindFirstChild(n) end
function Feint.DescendantsOf(m) return m:GetDescendants() end
function Feint.PlayingOf(s) return s.IsPlaying end
function Feint.AttrOf(i) return i:GetAttribute("FeintedAt") end
function Feint.IsFeintSound(v) return v.Name == "Feint" and v.ClassName == "Sound" end
function Feint.PlayerNamed(name) return Players:FindFirstChild(name) end
function Feint.SignalOf(inst, kind)
    if kind == "attr" then return inst:GetAttributeChangedSignal("FeintedAt") end
    return inst.ChildAdded
end
function Feint.ConnectTo(sig, fn) return sig:Connect(fn) end
function Feint.Disconnect(conn) conn:Disconnect() end

function Feint.KeyOf(inst)
    local ok, a = pcall(Feint.AddrOf, inst)
    if ok and a ~= nil then return a end
    return inst
end

-- fast path of the full scan: no pcall per instance (the caller wraps the whole loop in one pcall)
function Feint.CollectFeint(list, found)
    for i = 1, #list do
        local v = list[i]
        if v.Name == "Feint" and v.ClassName == "Sound" then found[Feint.KeyOf(v)] = v end
    end
end

-- names from the enemy model down to the sound's parent, e.g. { "HumanoidRootPart" } (empty = directly in the model)
function Feint.ChainFrom(model, s)
    local names = {}
    local okP, par = pcall(Feint.ParentOf, s)
    local mAddr = model.Address
    local depth = 0
    while okP and par and depth < 12 do
        local okA, a = pcall(Feint.AddrOf, par)
        if okA and a == mAddr then
            local out = {}
            for i = #names, 1, -1 do out[#out + 1] = names[i] end
            return out
        end
        local okN, n = pcall(Feint.NameOf, par)
        if not okN then return nil end
        names[#names + 1] = n
        okP, par = pcall(Feint.ParentOf, par)
        depth = depth + 1
    end
    return nil
end

function Feint.ResolvePath(st, chain)
    local cur = st.model
    local from = 1
    if chain[1] == "HumanoidRootPart" and st.hrp then
        cur, from = st.hrp, 2
    end
    for i = from, #chain do
        local ok, nxt = pcall(Feint.ChildOf, cur, chain[i])
        if not ok or not nxt then return nil end
        cur = nxt
    end
    return cur
end

-- LISTENERS ---------------------------------------------------------------------------------------

-- connects one validated listener; returns true when it worked
function Feint.Hook(st, inst, kind)
    local caps = Feint.Caps
    if caps[kind] == false then return false end -- tried a few times, this runtime has no such signal
    local conn = nil
    local ok, sig = pcall(Feint.SignalOf, inst, kind)
    if ok and sig ~= nil then
        local okC, c = pcall(Feint.ConnectTo, sig, kind == "attr" and st.onAttr or st.onChild)
        if okC and c ~= nil then conn = c end
    end
    if conn then
        st.conns[#st.conns + 1] = conn
        caps[kind] = true
        return true
    end
    Feint.Tries[kind] = Feint.Tries[kind] + 1
    if caps[kind] == nil and Feint.Tries[kind] >= 3 then caps[kind] = false end
    return false
end

-- listen for a new child (a Feint sound) on `inst`; one listener per instance per enemy
function Feint.WatchChildren(st, inst)
    if not inst or st.nWatched >= 6 then return end
    local key = Feint.KeyOf(inst)
    if st.watched[key] then return end
    st.watched[key] = true
    st.nWatched = st.nWatched + 1
    Feint.Hook(st, inst, "child")
end

-- remember where a Feint sound lives so every later poll looks there directly instead of scanning
function Feint.Learn(st, chain, s)
    local key = table.concat(chain, "/")
    if not Feint.PathSet[key] and #Feint.Paths < 8 then
        Feint.PathSet[key] = true
        Feint.Paths[#Feint.Paths + 1] = chain
    end
    local ok, par = pcall(Feint.ParentOf, s)
    if ok and par then Feint.WatchChildren(st, par) end
end

function Feint.OnAttr(st)
    if st.dead then return end
    Feint.Stats.signals = Feint.Stats.signals + 1
    Feint.CheckAttr(st, os.clock(), "event")
end

function Feint.OnChild(st, child)
    if st.dead then return end
    Feint.Stats.signals = Feint.Stats.signals + 1
    local now = os.clock()
    if child ~= nil then
        local ok, isFeint = pcall(Feint.IsFeintSound, child)
        if not ok or not isFeint then return end
        Feint.SeeSound(st, child, Feint.KeyOf(child), now, "event", false, true)
    else
        -- the runtime did not pass the child along: use the event as a trigger for an immediate look
        Feint.Poll(st, now, true)
    end
end

-- PUBLISHING --------------------------------------------------------------------------------------

-- records a feint for this enemy and tells every listener (the action queue) right away
function Feint.Mark(st, via, now, src)
    local last = st.last
    if last and now - last.at < Feint.MERGE then
        -- the same feint seen through a second signal: keep one event
        if not string.find(last.via, via, 1, true) then last.via = last.via .. " + " .. via end
        return last
    end
    st.seq = st.seq + 1
    local ev = { seq = st.seq, at = now, via = via, src = src }
    local ring = st.events
    ring[#ring + 1] = ev
    if #ring > 4 then table.remove(ring, 1) end
    st.last = ev
    if src == "event" then
        Feint.Stats.byEvent = Feint.Stats.byEvent + 1
    else
        Feint.Stats.byPoll = Feint.Stats.byPoll + 1
    end
    for i = 1, #Feint.Listeners do pcall(Feint.Listeners[i], st, ev) end
    return ev
end

-- the newest event that happened while this queued action's swing was playing, else nil
function Feint.Affects(st, q)
    local ring = st.events
    for i = #ring, 1, -1 do
        local ev = ring[i]
        if ev.at >= q.startAt - Feint.SLACK then return ev end
    end
    return nil
end

-- OBSERVATION -------------------------------------------------------------------------------------

-- "FeintedAt" attribute: its value changes whenever that player feints. Read on the character model and on the
-- Player object; the first value read from each is only remembered, any later change is a feint.
function Feint.CheckAttr(st, now, src)
    local changed = false
    local okM, vm = pcall(Feint.AttrOf, st.model)
    if okM then
        if st.attrModelReady and vm ~= st.attrModel then changed = true end
        st.attrModel, st.attrModelReady = vm, true
    end
    if st.isPlayer then
        if not st.player and now >= st.playerAt then
            local okF, p = pcall(Feint.PlayerNamed, st.name)
            if okF and p then st.player = p else st.playerAt = now + 2 end
        end
        if st.player then
            local okP, vp = pcall(Feint.AttrOf, st.player)
            if okP then
                if st.attrPlayerReady and vp ~= st.attrPlayer then changed = true end
                st.attrPlayer, st.attrPlayerReady = vp, true
                if not st.playerHooked then
                    st.playerHooked = true
                    Feint.Hook(st, st.player, "attr")
                end
            else
                -- the player left: look it up again later
                st.player, st.attrPlayerReady, st.playerHooked = nil, false, false
            end
        end
    end
    if changed and st.ready then Feint.Mark(st, "FeintedAt attribute", now, src) end
end

-- a Feint sound counts as a feint when it is a new instance, or a known one that starts playing again.
-- The first look at an enemy only seeds what is already there (a sound that is already playing counts).
function Feint.SeeSound(st, s, key, now, src, isCheap, justAdded)
    local cur
    if justAdded then
        cur = 2 -- a Feint sound that was just parented is the feint itself
    else
        local okP, playing = pcall(Feint.PlayingOf, s)
        cur = (okP and playing == true) and 2 or 1
    end
    local prev = st.seen[key]
    local fresh, how = false, "sound"
    if prev == nil then
        if st.ready then
            fresh = true
        elseif cur == 2 then
            fresh, how = true, "sound (already playing)"
        end
    elseif prev == 1 and cur == 2 then
        fresh, how = true, "sound (replayed)"
    end
    st.seen[key] = cur
    if isCheap then st.cheap[key] = true end

    if prev == nil then
        local chain = Feint.ChainFrom(st.model, s)
        if chain then
            Feint.Learn(st, chain, s)
            if fresh and how == "sound" then
                how = "sound under " .. (#chain > 0 and table.concat(chain, "/") or "model")
            end
        end
    end
    if fresh then Feint.Mark(st, how, now, src) end
end

-- polling fallback. `force` skips the 20 ms throttle; several callers in the same frame share one poll.
function Feint.Poll(st, now, force)
    if st.dead then return end
    if force then
        if st.polledAt == now then return end
    elseif now - st.polledAt < 0.02 then
        return
    end
    st.polledAt = now

    Feint.CheckAttr(st, now, "poll")

    local found, cheap = st.tmpFound, st.tmpCheap
    for k in pairs(found) do found[k] = nil end
    for k in pairs(cheap) do cheap[k] = nil end

    local paths = Feint.Paths
    for i = 1, #paths do
        local parent = Feint.ResolvePath(st, paths[i])
        if parent then
            local ok, s = pcall(Feint.ChildOf, parent, Feint.SOUND)
            if ok and s then
                local key = Feint.KeyOf(s)
                found[key], cheap[key] = s, true
            end
        end
    end

    -- full descendant scan: slow, so only while this enemy is mid-swing and at most every 250 ms; it only
    -- exists to discover sounds at spots we do not know yet
    local fullDone = false
    if now >= st.fullAt and now < st.animUntil then
        st.fullAt = now + 0.25
        local okD, list = pcall(Feint.DescendantsOf, st.model)
        if okD and type(list) == "table" then
            fullDone = true
            if not pcall(Feint.CollectFeint, list, found) then
                for _, v in ipairs(list) do
                    local okN, isFeint = pcall(Feint.IsFeintSound, v)
                    if okN and isFeint then found[Feint.KeyOf(v)] = v end
                end
            end
        end
    end

    for key, s in pairs(found) do
        Feint.SeeSound(st, s, key, now, "poll", cheap[key] == true, false)
    end

    -- forget sounds that are gone, so a new sound that reuses the same memory address still counts as new.
    -- Sounds at the spots checked every poll are dropped the moment they disappear; others after a full scan.
    for k in pairs(st.seen) do
        if st.cheap[k] then
            if not cheap[k] then st.seen[k], st.cheap[k] = nil, nil end
        elseif fullDone and not found[k] then
            st.seen[k] = nil
        end
    end
    for k in pairs(cheap) do st.cheap[k] = true end

    st.ready = true
end

-- LIFECYCLE ---------------------------------------------------------------------------------------

function Feint.Register(enemy)
    local st = {
        key = enemy.key, entry = enemy, model = enemy.model, hrp = enemy.hrp, name = enemy.name,
        isPlayer = enemy.isPlayer,
        seq = 0, events = {}, last = nil,
        seen = {}, cheap = {}, tmpFound = {}, tmpCheap = {},
        ready = false, dead = false,
        attrModel = nil, attrModelReady = false,
        attrPlayer = nil, attrPlayerReady = false, player = nil, playerAt = 0, playerHooked = false,
        animUntil = 0, polledAt = -math.huge, fullAt = 0,
        conns = {}, watched = {}, nWatched = 0, firedAt = nil,
    }
    st.onAttr = function() Feint.OnAttr(st) end
    st.onChild = function(child) Feint.OnChild(st, child) end
    Feint.States[st.key] = st
    Feint.Count = Feint.Count + 1

    Feint.Hook(st, st.model, "attr")
    Feint.WatchChildren(st, st.model)
    if st.hrp then Feint.WatchChildren(st, st.hrp) end
    for i = 3, #Feint.Paths do -- spots learned from earlier enemies
        local parent = Feint.ResolvePath(st, Feint.Paths[i])
        if parent then Feint.WatchChildren(st, parent) end
    end

    Feint.Poll(st, os.clock(), true) -- seed the current attribute values / sounds
    return st
end

-- idempotent: one state (and one set of listeners) per enemy, however often the enemy list is refreshed
function Feint.Ensure(enemy)
    local st = Feint.States[enemy.key]
    if st then
        if st.entry == enemy then return st end
        Feint.Remove(enemy.key) -- the entry was rebuilt (character replaced): start clean
    end
    return Feint.Register(enemy)
end

function Feint.Remove(key)
    local st = Feint.States[key]
    if not st then return end
    st.dead = true
    for i = 1, #st.conns do pcall(Feint.Disconnect, st.conns[i]) end
    st.conns, st.watched = {}, {}
    Feint.States[key] = nil
    Feint.Count = Feint.Count - 1
end

function Feint.Clear()
    for key in pairs(Feint.States) do Feint.Remove(key) end
end

-- drop every state whose enemy is no longer in the (freshly refreshed) enemy list
function Feint.PruneTo(list)
    if Feint.Count == 0 then return end
    local live = {}
    for i = 1, #list do live[list[i].key] = list[i] end
    for key, st in pairs(Feint.States) do
        if live[key] ~= st.entry then Feint.Remove(key) end
    end
end

function Feint.CapStr(v) return v == true and "on" or (v == false and "off" or "?") end

function Feint.Describe()
    local c, s = Feint.Caps, Feint.Stats
    return string.format("%s/%s | %d | %dE %dP",
        Feint.CapStr(c.attr), Feint.CapStr(c.child), Feint.Count, s.byEvent, s.byPoll)
end

-- ACTION QUEUE HOOK -------------------------------------------------------------------------------
-- The moment a feint is published, every still-queued action of THAT enemy whose swing was already playing is
-- flagged. Nothing is pressed, delayed or rescheduled here; FireDue just reads the flag when the action is due.
Feint.Listeners[1] = function(st, ev)
    if not Get("sb_feint_detect") then return end
    local pend, soon = 0, nil
    for i = 1, #Queue do
        local q = Queue[i]
        if q.st == st then
            if not q.feint and ev.at >= q.startAt - Feint.SLACK then q.feint = ev end
            if q.feint == ev then
                pend = pend + 1
                local d = (q.at - ev.at) * 1000
                if not soon or d < soon then soon = d end
            end
        end
    end
    if Get("print_feints") then
        local sinceFire = st.firedAt and (ev.at - st.firedAt) * 1000 or nil
        Log(string.format("Feint #%d on %s (%s) | %d queued action(s) cancelled%s%s",
            ev.seq, DisplayName(st.name), ev.via, pend,
            soon and string.format(", next was due in %.0fms", soon) or "",
            (sinceFire and sinceFire < 1000) and string.format(" | an action already went out %.0fms earlier (too late to cancel)", sinceFire) or ""))
    end
end
end

-- should this parry action press Q instead of F? (Prioritize Dodge, or a roll of Randomize Dodge Chance)
local function ShouldDodge()
    if Get("sb_dodge_priority") then return true end
    local chance = Get("sb_dodge_chance") or 0
    return chance > 0 and math.random(1, 100) <= chance
end

-- report(stage, configuredMs) is optional: the Test buttons use it to show every step of the sequence
local function Perform(kind, hold, tag, model, id, report, meta)
    local isTest = meta and meta.test
    local swapped = false
    if kind == "parry" and ShouldDodge() then
        kind, swapped = "dodge", true
    end
    if kind == "dodge" or kind == "unparryable" then
        local cooldown = (Get("sb_dodge_cooldown") or 1500) / 1000
        local now = os.clock()
        if not isTest and cooldown > 0 and now - Combat.lastDodge < cooldown then
            -- dodged too recently: parry (F) until the cooldown is over
            kind = "parry"
            tag = tag .. string.format(" (dodge on cooldown, %.0fms left, parrying)", (cooldown - (now - Combat.lastDodge)) * 1000)
        else
            if not isTest then Combat.lastDodge = now end
            if swapped then tag = tag .. " (parry swapped to dodge)" end
        end
    end
    local vk, h = ActionKey(kind, hold)
    PressKey(vk, h)
    if meta and meta.akey then HitWatch.Fired(meta.akey, KeyName(vk)) end
    if report then report("Pressed " .. KeyName(vk) .. " (" .. kind .. ")", 0) end


    if Get("print_parries") then
        local okN, nm = pcall(function() return model.Name end)
        local timing = ""
        if meta and meta.seenAt then
            timing = string.format(" | fired %.0fms after seen", (os.clock() - meta.seenAt) * 1000)
            if meta.startAt then
                timing = timing .. string.format(" (anim at %.3fs)", os.clock() - meta.startAt)
            end
        end
        Log(string.format("%s%s -> %s | %s | %s%s",
            kind, tag, KeyName(vk),
            okN and DisplayName(nm) or "?", AnimNameId(id), timing))
    end
end

do
    -- Test button waits 3 seconds (click back into the game), then fires a dodge through the same
    -- Perform path as real actions.
    local testBusy = false

    local function TestAction(title, kind)
        toolsSec:AddButton({
            Title = title,
            ButtonText = "Run in 3s",
            Callback = function()
                if testBusy then return end
                testBusy = true
                Nexa:Notify({ Title = title, Content = "Fires in 3 seconds", Type = "info", Duration = 3 })
                task.wait(3)

                if Nexa:IsAlive() then
                    Perform(kind, 0.05, " (test)", { Name = "Test" }, "test", function(stage)
                        Log("Test: " .. stage)
                        Nexa:Notify({ Title = title, Content = stage, Type = "info", Duration = 3 })
                    end, { test = true })
                    task.wait(0.4)
                end
                testBusy = false
            end,
        })
    end
    TestAction("Test Dodge", "dodge")
end

-- UNLOAD: fully destroys the script. Nexa:Destroy() ends every loop (they all run `while Nexa:IsAlive()`),
-- removes all drawings, releases the held keys (see OnDestroy below) and gives the game its input back. The
-- exported globals are cleared too so nothing keeps a reference to the dead library.
scriptSec:AddButton({
    Title = "",
    ButtonText = "Unload Script",
    Variant = "danger",
    Expand = true,
    Callback = function()
        task.spawn(function()
            pcall(function() Nexa:Destroy() end)
            -- remove everything the UI drew, then once more shortly after in case something was redrawn
            local removed = RemoveTrackedDrawings()
            task.wait(0.25)
            removed = removed + RemoveTrackedDrawings()
            if removed == 0 and type(cleardrawcache) == "function" then pcall(cleardrawcache) end
            if DrawingLib and OrigDrawingNew then pcall(function() DrawingLib.new = OrigDrawingNew end) end
            if type(setrobloxinput) == "function" then pcall(setrobloxinput, true) end
            pcall(function()
                local env = type(getgenv) == "function" and getgenv() or nil
                for _, k in ipairs({ "Nexa", "UI", "DrawingUI" }) do
                    if env and env[k] == Nexa then env[k] = nil end
                    if rawget(_G, k) == Nexa then _G[k] = nil end
                    if type(shared) == "table" and shared[k] == Nexa then shared[k] = nil end
                end
            end)
        end)
    end,
})

-- Every action is queued at startTime + action.t - ping comp and pressed as soon as it is due (next frame at the
-- latest). Detect Feints only decides whether to skip it; it never waits or delays anything.
-- `fst` is the enemy's feint state (nil when Detect Feints is off); it is only stored on the queue entry.
local function Schedule(startTime, info, akey, model, id, fst)
    local Feint = Combat.Feint
    local delay = 0
    local ping  = GetPingComp()
    local hold  = 0.05
    local now   = os.clock()

    for _, action in ipairs(info.actions) do
        local base = startTime + action.t
        if base >= now - 0.1 then
            local at = base + ((delay - ping) / 1000)
            local entry = {
                at         = at,
                hold       = hold,
                kind       = action.kind,
                owner      = akey,
                model      = model,
                st         = fst,
                id         = id,
                seenAt     = now,
                startAt    = startTime,
                actionT    = action.t,
                baseSeq    = fst and fst.seq or 0,
            }
            Queue[#Queue + 1] = entry
            if fst then
                -- keep the monitor's fallback poll running until the last queued action is due
                if at + 0.1 > fst.animUntil then fst.animUntil = at + 0.1 end
                -- a feint that already happened after this swing started (before the scan noticed the swing)
                local ev = Feint.Affects(fst, entry)
                if ev then entry.feint = ev end
            end
            if Get("print_parries") then
                local okN, nm = pcall(function() return model.Name end)
                Log(string.format("Queued %s@%.3f | %s | %s | animation was already %.0fms in, action due in %.0fms",
                    action.kind, action.t, okN and DisplayName(nm) or "?", AnimNameId(id),
                    (now - startTime) * 1000, (at - now) * 1000))
            end
        end
    end
end

local function FireDue()
    if #Queue == 0 then return end
    local Feint = Combat.Feint
    local t = os.clock()
    local watchFeint = Get("sb_feint_detect")
    for i = #Queue, 1, -1 do
        local q = Queue[i]
        -- due: press now. The feint monitor has already published anything it saw (q.feint, set the moment the
        -- feint was detected); this only reads that state, so nothing here waits or polls.
        if t >= q.at then
            local ev = nil
            if watchFeint then
                ev = q.feint
                if not ev and q.st then
                    ev = Feint.Affects(q.st, q)
                    if ev then q.feint = ev end
                end
            end
            -- a published feint, or a swing that stopped early without any signal, skips the action
            local feinted = ev ~= nil or not IsAnimAlive(q.model, q.id)
            local fire, tag = not feinted, ""

            if feinted and math.random(1, 100) <= (Get("sb_parry_feint_chance") or 0) then
                fire, tag = true, " (feint)"
            end

            if feinted and Get("print_feints") then
                local okN, nm = pcall(function() return q.model.Name end)
                local why = ev
                    and string.format("feint #%d (%s) published %.0fms after the animation started", ev.seq, ev.via, (ev.at - q.startAt) * 1000)
                    or "animation had stopped early"
                Log(string.format("Feint (%s) | %s | %s | %s@%.3f | %s | checked %.0fms in, action was due at %.0fms | %s",
                    ev and "signal" or "animation", okN and DisplayName(nm) or "?", AnimNameId(q.id),
                    q.kind, q.actionT or 0, why,
                    (t - q.startAt) * 1000, (q.at - q.startAt) * 1000,
                    fire and "acted anyway (Parry Feint Chance)" or "skipped"))
            end

            if fire then
                if q.st then q.st.firedAt = os.clock() end
                Perform(q.kind, q.hold, tag, q.model, q.id, nil, { seenAt = q.seenAt, startAt = q.startAt, akey = q.owner })
            end

            table.remove(Queue, i)
        end
    end
end

local function ScanStep(now)
    local scanStart = os.clock()
    local Feint = Combat.Feint

    if now >= NextRefresh then
        RefreshEnemies(now)
        NextRefresh = now + 0.5
        Feint.PruneTo(Enemies) -- enemies that left (or respawned as a new model) lose their state + listeners
    end

    local doPlayers, doNpcs = cPlayers.Value, cNpcs.Value
    local useGeneral = cGeneral.Value
    local generalRange = cRange.Value or 20
    -- enemies further than this are skipped without reading their animations
    local nearRange = (useGeneral and generalRange or math.max(AnimMaxRange, DEFAULT_ANIM_RANGE)) * 1.5
    local seenNow, tracked = {}, 0
    local skipFaction = (not cSameFaction.Value) and MyFaction or nil
    local watchFeint = Get("sb_feint_detect")
    if not watchFeint and Feint.Count > 0 then Feint.Clear() end

    for _, enemy in ipairs(Enemies) do
        if ((enemy.isPlayer and doPlayers) or (not enemy.isPlayer and doNpcs))
           and not (enemy.isPlayer and FriendsLower[enemy.lname])
           and not (skipFaction and enemy.isPlayer and enemy.faction == skipFaction)
           and now >= enemy.skipUntil then

            local dist = Dist(enemy)
            if dist > nearRange then
                enemy.skipUntil = now + 0.3
                -- well out of reach: stop listening to this enemy (hysteresis so it does not flap at the edge)
                if dist > nearRange * 2 and Feint.States[enemy.key] then Feint.Remove(enemy.key) end
            else
                local fs = nil
                if watchFeint then
                    fs = Feint.Ensure(enemy)       -- registers listeners once per enemy
                    Feint.Poll(fs, now, false)     -- throttled fallback check
                end
                for _, anim in ipairs(GetPlayingAnims(enemy)) do
                    local id   = anim.id
                    local info = AnimDB[id]
                    if info then
                        if fs and now + 0.25 > fs.animUntil then fs.animUntil = now + 0.25 end -- keeps the fallback poll on this enemy
                        local akey = enemy.key .. "|" .. id
                        tracked = tracked + 1
                        seenNow[akey] = true

                        if not Active[akey] then
                            Status.last, Status.lastDist = info.name or id, dist

                            local animRange = useGeneral and generalRange or info.range or DEFAULT_ANIM_RANGE
                            local scheduled = false
                            if dist <= animRange and math.random(1, 100) <= (cChance.Value or 100) then
                                local start = os.clock() - (anim.elapsed or 0)
                                Active[akey] = start
                                Schedule(start, info, akey, enemy.model, id, fs)
                                scheduled = true
                            else
                                Active[akey] = now
                            end
                            HitWatch.Start(akey, enemy, info, id, dist, anim.elapsed or 0, scheduled)
                        end
                    end
                end
            end
        end
    end

    for k in pairs(Active) do
        if not seenNow[k] then Active[k] = nil end
    end
    Status.tracked = tracked
    Status.scanMs = Status.scanMs * 0.8 + (os.clock() - scanStart) * 1000 * 0.2
end

-- AUTOMATION LOGIC
-- Wrapped in do...end so its locals don't count against the script's top-level local limit.
do
    local function child(root, ...)
        local current = root
        for _, name in ipairs({ ... }) do
            current = current and current:FindFirstChild(name)
            if not current then return nil end
        end
        return current
    end

    local function localRoot()
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function teleport(pos)
        local root = localRoot()
        if not root then return false end
        root.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
        return true
    end

    local function on(flag)
        return Nexa:IsAlive() and Get(flag)
    end

    -- waits up to `seconds`, returning false early if the toggle is turned off
    local function waitFor(flag, seconds)
        local untilAt = os.clock() + seconds
        while os.clock() < untilAt do
            if not on(flag) then return false end
            task.wait(0.05)
        end
        return on(flag)
    end

    local function MoveMouse(x, y)
        if type(mousemoveabs) == "function" then
            pcall(mousemoveabs, x, y)
        end
    end

    local function LeftClick()
        if type(mouse1click) == "function" then
            pcall(mouse1click)
        elseif type(mouse1press) == "function" and type(mouse1release) == "function" then
            pcall(mouse1press)
            task.wait(0.03)
            pcall(mouse1release)
        end
    end

    -- AUTO LOG (STR)
    local LOG_A = Vector3.new(-4395.79, 305, -2580.49)
    local LOG_B = Vector3.new(-4222.28, 305, -2578.24)

    task.spawn(function()
        local lastErr
        while Nexa:IsAlive() do
            if Get("auto_log") then
                local ok, err = pcall(function()
                    if not teleport(LOG_A) then task.wait(0.5) return end
                    if not waitFor("auto_log", 1) then return end
                    -- spam E for about half a second
                    local spamUntil = os.clock() + 0.5
                    while os.clock() < spamUntil and on("auto_log") do
                        PressKey(KEY_E, 0.03)
                        task.wait(0.06)
                    end
                    if not on("auto_log") then return end
                    teleport(LOG_B)
                    waitFor("auto_log", 0.5)
                end)
                if not ok and err ~= lastErr then lastErr = err warn(LOG_TAG .. " auto log error: " .. tostring(err)) end
                task.wait()
            else
                task.wait(0.25)
            end
        end
    end)

    -- AUTO MEDITATE (FOCUS)
    local MEDITATE_MIN_YEN = 25
    local ORB_MAX_SIZE = 150 -- only frames this small (px) count as orbs

    -- "¥25" -> 25, "¥2.0K" -> 2000, "¥1.5M" -> 1500000
    local function readYen()
        local lp = Players.LocalPlayer
        local yenObj = child(lp, "PlayerGui", "HUD", "Currency", "Yen")
        if not yenObj then return nil end
        local ok, text = pcall(function() return yenObj.Text end)
        if not ok or type(text) ~= "string" then return nil end
        text = text:gsub(",", "")
        local num, suffix = text:match("([%d%.]+)%s*([KkMmBb]?)")
        num = tonumber(num)
        if not num then return nil end
        local mult = ({ k = 1e3, m = 1e6, b = 1e9 })[string.lower(suffix or "")] or 1
        return num * mult
    end

    local function instPosition(inst)
        -- a plain part: just read Position (errors on a Model, which is fine inside pcall)
        local okDirect, direct = pcall(function() return inst.Position end)
        if okDirect and direct then return direct end
        local okPrimary, primary = pcall(function() return inst.PrimaryPart.Position end)
        if okPrimary and primary then return primary end
        local okC, cf = pcall(function() return inst.CFrame end)
        if okC and cf then return cf.Position end
        local okM, pivot = pcall(function() return inst:GetPivot() end)
        if okM and pivot then return pivot.Position end
        local okP, isPart = pcall(function() return inst:IsA("BasePart") end)
        if okP and isPart then return inst.Position end
        local okD, list = pcall(function() return inst:GetDescendants() end)
        if okD and type(list) == "table" then
            for _, d in ipairs(list) do
                local okB, isBase = pcall(function() return d:IsA("BasePart") end)
                if okB and isBase then return d.Position end
            end
        end
        return nil
    end

    local function pickMat()
        local mats = child(workspace, "TrainingAreas", "Blood Focus Arena", "Mats")
        if not mats then
            local area = child(workspace, "TrainingAreas")
            local arena = area and area:FindFirstChild("Blood Focus Arena")
            Log("Auto Mediate: Mats folder not found. TrainingAreas "
                .. (area and "exists" or "MISSING") .. ", Blood Focus Arena " .. (arena and "exists" or "MISSING"))
            if arena then
                local names = {}
                for _, c in ipairs(arena:GetChildren()) do names[#names + 1] = c.Name end
                Log("Blood Focus Arena children: " .. table.concat(names, ", "))
            end
            return nil
        end
        -- mats are named "Focus Mat 1" .. "Focus Mat 8"; pick one at random so it isn't always the same mat
        local order = { 1, 2, 3, 4, 5, 6, 7, 8 }
        for i = #order, 2, -1 do
            local j = math.random(1, i)
            order[i], order[j] = order[j], order[i]
        end
        for _, n in ipairs(order) do
            local mat = mats:FindFirstChild("Focus Mat " .. n)
            -- the main part of each mat is its child named "Mat"
            local main = mat and mat:FindFirstChild("Mat")
            local pos = main and instPosition(main)
            if pos then return pos + Vector3.new(0, 3, 0) end
        end

        -- nothing matched the "Focus Mat N" names: try any child, and say what is actually in the folder
        local names = {}
        for _, c in ipairs(mats:GetChildren()) do
            local okCls, cls = pcall(function() return c.ClassName end)
            names[#names + 1] = c.Name .. ":" .. (okCls and cls or "?")
            local pos = instPosition(c:FindFirstChild("Mat") or c)
            if pos then return pos + Vector3.new(0, 3, 0) end
        end
        Log("Auto Mediate: Mats found but no position could be read. Children: "
            .. (#names > 0 and table.concat(names, ", ") or "(none)"))
        return nil
    end

    -- centre of a GUI object in screen pixels
    local function guiCenter(obj)
        local ok, x, y = pcall(function()
            local p, s = obj.AbsolutePosition, obj.AbsoluteSize
            return p.X + s.X * 0.5, p.Y + s.Y * 0.5
        end)
        if ok then return x, y end
        return nil
    end

    -- the orb frame whose centre is closest to the top-left corner (0, 0), or nil if there are none
    local function closestOrb()
        local arena = child(Players.LocalPlayer, "PlayerGui", "Minigames", "ArenaHUD")
        if not arena then return nil end
        local okD, list = pcall(function() return arena:GetDescendants() end)
        if not okD or type(list) ~= "table" then return nil end

        local bestX, bestY, bestDist
        for _, d in ipairs(list) do
            local ok, isFrame = pcall(function() return d.ClassName == "Frame" and d.Visible end)
            if ok and isFrame then
                local okS, w, h = pcall(function() return d.AbsoluteSize.X, d.AbsoluteSize.Y end)
                if okS and w > 0 and h > 0 and w <= ORB_MAX_SIZE and h <= ORB_MAX_SIZE then
                    local x, y = guiCenter(d)
                    if x then
                        local dist = math.sqrt(x * x + y * y)
                        if not bestDist or dist < bestDist then bestX, bestY, bestDist = x, y, dist end
                    end
                end
            end
        end
        return bestX, bestY
    end

    local function MeditateSequence()
        local yen = readYen()
        if not yen then
            Log("Auto Mediate: could not read your yen (HUD.Currency.Yen)")
            return false
        end
        if yen <= MEDITATE_MIN_YEN then
            Log("Auto Mediate: need more than " .. MEDITATE_MIN_YEN .. " yen (you have " .. yen .. "), turning off")
            Nexa:Notify({ Title = "Auto Mediate", Content = "Not enough yen (need more than 25).", Type = "warning", Duration = 4 })
            local c = Controls.auto_mediate
            if c then pcall(function() c:SetValue(false) end) end
            return false
        end

        local mat = pickMat()
        if not mat then
            Log("Auto Mediate: no mat found under TrainingAreas.Blood Focus Arena.Mats")
            return false
        end
        teleport(mat)
        if not waitFor("auto_mediate", 0.5) then return false end
        PressKey(KEY_E, 0.05)
        if not waitFor("auto_mediate", 0.5) then return false end

        local yes = child(Players.LocalPlayer, "PlayerGui", "ConfirmationGui", "Frame", "BottomBar", "Choices", "YesBtn", "Label")
        local x, y = yes and guiCenter(yes)
        if not x then
            Log("Auto Mediate: confirmation button not found")
            return false
        end
        MoveMouse(x, y)
        if not waitFor("auto_mediate", 0.5) then return false end
        LeftClick()
        return true
    end

    -- the minigame counts as "up" while ArenaHUD exists (and isn't hidden, if it has a Visible/Enabled flag)
    local function arenaUp()
        local arena = child(Players.LocalPlayer, "PlayerGui", "Minigames", "ArenaHUD")
        if not arena then return false end
        local okV, vis = pcall(function() return arena.Visible end)
        if okV and type(vis) == "boolean" then return vis end
        local okE, en = pcall(function() return arena.Enabled end)
        if okE and type(en) == "boolean" then return en end
        return true
    end

    local ARENA_START_TIMEOUT = 10 -- if ArenaHUD never shows up after confirming, try again
    local ARENA_GONE_DELAY = 0.5   -- ArenaHUD must stay gone this long before it counts as finished

    task.spawn(function()
        -- idle: start a session. waiting: session started, ArenaHUD not seen yet. inside: ArenaHUD is up.
        local state, nextTry, startedAt, goneAt, lastErr = "idle", 0, 0, nil, nil
        while Nexa:IsAlive() do
            if Get("auto_mediate") then
                local ok, err = pcall(function()
                    local now = os.clock()
                    local up = arenaUp()

                    if state == "idle" then
                        if up then
                            -- already in the minigame (started by hand): treat it as a running session
                            state, goneAt = "inside", nil
                        elseif now >= nextTry then
                            if MeditateSequence() then
                                state, startedAt = "waiting", os.clock()
                            else
                                nextTry = os.clock() + 1.5
                            end
                        end
                    elseif state == "waiting" then
                        if up then
                            state, goneAt = "inside", nil
                        elseif now - startedAt > ARENA_START_TIMEOUT then
                            Log("Auto Mediate: ArenaHUD never appeared, trying again")
                            state, nextTry = "idle", 0
                        end
                    end

                    if state == "inside" then
                        if up then
                            goneAt = nil
                            local ox, oy = closestOrb()
                            if ox then MoveMouse(ox, oy) end
                        else
                            goneAt = goneAt or now
                            if now - goneAt >= ARENA_GONE_DELAY then
                                -- ArenaHUD popped up and went away: the session is over, start the next one
                                state, nextTry, goneAt = "idle", 0, nil
                            end
                        end
                    end
                end)
                if not ok and err ~= lastErr then lastErr = err warn(LOG_TAG .. " auto mediate error: " .. tostring(err)) end
                task.wait(0.02)
            else
                state, nextTry, goneAt = "idle", 0, nil
                task.wait(0.25)
            end
        end
    end)
end

-- SPAM E (QOL)
-- Taps E continuously while the toggle is on and stops whenever the Roblox chat box is focused. Chat focus is
-- checked several ways because executors expose different parts of the engine; if none of them work the
-- chat can't be detected and E keeps tapping while you type.
do
    local UIS = game:GetService("UserInputService")

    local function walk(root, ...)
        local cur = root
        for _, name in ipairs({ ... }) do
            cur = cur and cur:FindFirstChild(name)
            if not cur then return nil end
        end
        return cur
    end

    local function ChatOpen()
        local ok, box = pcall(function() return UIS:GetFocusedTextBox() end)
        if ok and box then return true end

        -- new TextChatService input bar
        local okT, focused = pcall(function()
            return game:GetService("TextChatService").ChatInputBarConfiguration.IsFocused
        end)
        if okT and focused == true then return true end

        -- the chat bar's TextBox in CoreGui (new chat) or PlayerGui (legacy chat)
        local okC, tb = pcall(function()
            return walk(game:GetService("CoreGui"), "ExperienceChat", "appLayout", "chatInputBar", "Background", "Container", "TextContainer", "TextBoxContainer", "TextBox")
        end)
        if okC and tb then
            local okF, f = pcall(function() return tb:IsFocused() end)
            if okF and f then return true end
        end
        local okL, legacy = pcall(function()
            local lp = Players.LocalPlayer
            return walk(lp and lp:FindFirstChild("PlayerGui"), "Chat", "Frame", "ChatBarParentFrame", "Frame", "BoxFrame", "Frame", "ChatBar")
        end)
        if okL and legacy then
            local okF, f = pcall(function() return legacy:IsFocused() end)
            if okF and f then return true end
        end
        return false
    end

    task.spawn(function()
        while Nexa:IsAlive() do
            if Get("spam_e") then
                if not ChatOpen() then PressKey(KEY_E, 0.05) end
                task.wait(0.05)
            else
                task.wait(0.25)
            end
        end
    end)
end

-- FEINT WATCHER (fallback poll)
-- Its own loop, independent of the parry path. The event listeners (Combat.Feint) do the fast work where the runtime
-- supports them; this loop polls every enemy that is mid-swing (or has an action queued) every "Feint Check Rate" ms
-- so a feint is still caught if a signal never fires. It publishes through Feint.Mark, never presses anything and
-- never delays anything.
do
    task.spawn(function()
        local nextText = 0
        while Nexa:IsAlive() do
            local Feint = Combat.Feint
            local now = os.clock()
            if now >= nextText then
                nextText = now + 0.25
                Status.feint = Feint.Describe()
            end
            if cOn.Value and Get("sb_feint_detect") and Feint.Count > 0 then
                for _, st in pairs(Feint.States) do
                    if now < st.animUntil then pcall(Feint.Poll, st, now, true) end
                end
                task.wait((Get("sb_feint_rate") or 5) / 1000)
            else
                task.wait(0.1)
            end
        end
    end)
end

-- STARTUP
LoadData()
LoadIgnored()
RefreshHistLabels()

Nexa:Notify({
    Title = GAME_NAME,
    Content = "Loaded " .. Status.loaded .. " animations. Press P to toggle the menu.",
    Type = "success",
    Duration = 5,
})

task.spawn(function()
    task.wait(1)
    ApplyPing(6, true)
end)

Nexa:OnDestroy(function()
    for _, r in ipairs(Releases) do pcall(keyrelease, r.vk) end
    Releases = {}
    Queue, Active, Tracked, TrackedCount = {}, {}, {}, 0
    -- disconnect every feint listener
    pcall(function() Combat.Feint.Clear() end)
    -- never leave the game's input blocked after the script is gone
    if type(setrobloxinput) == "function" then pcall(setrobloxinput, true) end
end)

task.spawn(function()
    local lastLoop, lastScan, lastErr = os.clock(), 0, nil

    while Nexa:IsAlive() do
        local now = os.clock()
        -- nothing to scan, track or release: sleep longer instead of spinning every frame
        local idle = not cOn.Value and TrackedCount == 0 and #Releases == 0
        if not idle then
            Status.loopMs = Status.loopMs * 0.8 + (now - lastLoop) * 1000 * 0.2
        end
        lastLoop = now

        if #Releases > 0 then
            for i = #Releases, 1, -1 do
                if now >= Releases[i].at then
                    pcall(keyrelease, Releases[i].vk)

                    table.remove(Releases, i)
                end
            end
        end

        if cOn.Value then
            if Controls.sb_t_autoping.Value then UpdateAutoPing(now) end
            if now - lastScan >= SCAN_INTERVAL then
                lastScan = now
                local ok, err = pcall(ScanStep, now)
                if not ok and err ~= lastErr then lastErr = err warn(LOG_TAG .. " scan error: " .. tostring(err)) end
            end
            if #Queue > 0 then
                local ok, err = pcall(FireDue)
                if not ok and err ~= lastErr then lastErr = err warn(LOG_TAG .. " fire error: " .. tostring(err)) end
            end
        else
            if #Queue > 0 then Queue = {} end
            if next(Active) ~= nil then Active = {} end
            -- auto parry is off: stop listening to every enemy
            if Combat.Feint.Count > 0 then Combat.Feint.Clear() end
        end

        if TrackedCount > 0 and now >= nextTrackerAt then
            nextTrackerAt = now + TRACKER_INTERVAL
            local ok, err = pcall(TrackerStep)
            if not ok and err ~= lastErr then lastErr = err warn(LOG_TAG .. " tracker error: " .. tostring(err)) end
        end

        if Get("debug_hits") then
            pcall(HitWatch.Step, now)
        elseif next(HitWatch.list) ~= nil then
            HitWatch.list = {}
        end

        if now - lastStatusUpdate >= 0.25 then pcall(UpdateStatusUI, now) end
        if idle then task.wait(0.1) else task.wait() end
    end

    for _, r in ipairs(Releases) do pcall(keyrelease, r.vk) end
end)

return Nexa
