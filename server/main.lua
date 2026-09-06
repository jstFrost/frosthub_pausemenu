local sessionSeconds = {}   -- identifier -> live total, in seconds
local sourceIdentifier = {} -- server id -> identifier, only while connected
local dirty = {}            -- identifier -> has unsaved seconds
local loading = {}          -- identifier -> a load is already in flight

local SAVE_QUERY =
    'INSERT INTO frosthub_playtime (identifier, seconds) VALUES (?, ?) ' ..
    'ON DUPLICATE KEY UPDATE seconds = ?'

-- Reads the stored total BEFORE the player starts ticking. Seeding the counter
-- with a 0 and filling it in asynchronously meant the first menu open always
-- showed zero, and a save landing in that window overwrote the real total.
local function trackPlayer(src)
    local identifier = ServerBridge.GetIdentifier(src)
    if not identifier then return nil end

    if loading[identifier] then
        local deadline = GetGameTimer() + 10000
        while loading[identifier] and GetGameTimer() < deadline do Wait(50) end
    elseif sessionSeconds[identifier] == nil then
        loading[identifier] = true
        local stored = MySQL.scalar.await('SELECT seconds FROM frosthub_playtime WHERE identifier = ?', { identifier })
        sessionSeconds[identifier] = tonumber(stored) or 0
        loading[identifier] = nil
    end

    sourceIdentifier[src] = identifier
    return identifier
end

local function stillOnline(identifier)
    for _, id in pairs(sourceIdentifier) do
        if id == identifier then return true end
    end
    return false
end

-- Drops an identifier from memory once nobody holding it is connected, so the
-- tables no longer grow for the lifetime of the resource.
local function releaseIdentifier(identifier)
    if not identifier or stillOnline(identifier) then return end

    if dirty[identifier] then
        MySQL.prepare.await(SAVE_QUERY, {
            identifier,
            sessionSeconds[identifier] or 0,
            sessionSeconds[identifier] or 0,
        })
        dirty[identifier] = nil
    end

    sessionSeconds[identifier] = nil
end

local function flush()
    local rows = {}

    for identifier in pairs(dirty) do
        local seconds = sessionSeconds[identifier] or 0
        rows[#rows + 1] = { identifier, seconds, seconds }
        dirty[identifier] = nil
    end

    if not rows[1] then return end
    MySQL.prepare.await(SAVE_QUERY, rows)
end

local function resolveGang(src)
    local resolver = Config.GangResolver
    if not resolver then return nil end

    if type(resolver) == 'function' then
        local ok, result = pcall(resolver, src)
        return ok and result or nil
    end

    if resolver == 'rcore_gangs' then
        local ok, gang = pcall(function() return exports.rcore_gangs:GetPlayerGang(src) end)
        return ok and gang and gang.name or nil
    elseif resolver == 'qbcore' then
        local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if not ok or not core then return nil end
        local player = core.Functions.GetPlayer(src)
        return player and player.PlayerData.gang and player.PlayerData.gang.label or nil
    elseif resolver == 'qbox' then
        local ok, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        return ok and player and player.PlayerData.gang and player.PlayerData.gang.label or nil
    end

    return nil
end

lib.callback.register('frosthub_pausemenu:getPlayer', function(src)
    local raw = ServerBridge.GetRawPlayer(src)
    if not raw then
        Config.Debug_Print(('getPlayer: no data for source %s (framework=%s)'):format(src, ServerBridge.framework))
        return {}
    end

    local identifier = sourceIdentifier[src] or trackPlayer(src)

    return {
        source      = src,
        name        = raw.name,
        job         = raw.job,
        gang        = resolveGang(src),
        cash        = raw.cash,
        bank        = raw.bank,
        playSeconds = identifier and sessionSeconds[identifier] or 0,
    }
end)

-- Playtime is counted for everyone from the moment they join, not from the
-- first time they happen to open the menu.
AddEventHandler('playerJoining', function()
    trackPlayer(source)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, src in ipairs(GetPlayers()) do
        trackPlayer(tonumber(src))
    end
end)

CreateThread(function()
    while true do
        Wait(60000)

        -- Stale entries are collected first and released afterwards: the
        -- release writes to the database, and yielding mid-traversal would let
        -- a joining player mutate the table we are walking.
        local stale = {}

        for src, identifier in pairs(sourceIdentifier) do
            if GetPlayerName(src) then
                sessionSeconds[identifier] = (sessionSeconds[identifier] or 0) + 60
                dirty[identifier] = true
            else
                stale[#stale + 1] = { src = src, identifier = identifier }
            end
        end

        for _, entry in ipairs(stale) do
            sourceIdentifier[entry.src] = nil
            releaseIdentifier(entry.identifier)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        flush()
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier = sourceIdentifier[src]
    sourceIdentifier[src] = nil
    releaseIdentifier(identifier)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local placeholders, params, count = {}, {}, 0

    for identifier in pairs(dirty) do
        count = count + 1
        placeholders[count] = '(?, ?)'
        params[#params + 1] = identifier
        params[#params + 1] = sessionSeconds[identifier] or 0
    end

    if count == 0 then return end

    -- One blocking statement instead of one query per player: the resource is
    -- already going down and will not wait for a queue of async writes.
    MySQL.Sync.execute(
        'INSERT INTO frosthub_playtime (identifier, seconds) VALUES ' ..
        table.concat(placeholders, ', ') ..
        ' ON DUPLICATE KEY UPDATE seconds = VALUES(seconds)',
        params
    )

    Config.Print(('saved playtime for %d players before stopping'):format(count))
end)

RegisterNetEvent('frosthub_pausemenu:leaveServer', function()
    DropPlayer(source, 'You disconnected from the server.')
end)
