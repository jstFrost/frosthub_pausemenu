local sessionSeconds = {}
local sourceIdentifier = {}

local function loadPlaytime(identifier, onLoaded)
    MySQL.Async.fetchScalar('SELECT seconds FROM frosthub_playtime WHERE identifier = ?', { identifier }, function(seconds)
        onLoaded(seconds or 0)
    end)
end

local function savePlaytime(identifier, seconds)
    if not identifier then return end
    MySQL.Async.execute(
        'INSERT INTO frosthub_playtime (identifier, seconds) VALUES (?, ?) ON DUPLICATE KEY UPDATE seconds = ?',
        { identifier, seconds, seconds }
    )
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

    local identifier = ServerBridge.GetIdentifier(src)
    sourceIdentifier[src] = identifier

    if identifier and sessionSeconds[identifier] == nil then
        sessionSeconds[identifier] = 0
        loadPlaytime(identifier, function(seconds) sessionSeconds[identifier] = seconds end)
    end

    return {
        source      = src,
        name        = raw.name,
        job         = raw.job,
        gang        = resolveGang(src),
        cash        = raw.cash,
        bank        = raw.bank,
        playSeconds = sessionSeconds[identifier] or 0,
    }
end)

CreateThread(function()
    while true do
        Wait(60000)
        for src, identifier in pairs(sourceIdentifier) do
            if identifier and GetPlayerName(src) then
                sessionSeconds[identifier] = (sessionSeconds[identifier] or 0) + 60
            else
                sourceIdentifier[src] = nil
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        for identifier, seconds in pairs(sessionSeconds) do
            savePlaytime(identifier, seconds)
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier = sourceIdentifier[src]
    if identifier then
        savePlaytime(identifier, sessionSeconds[identifier] or 0)
    end
    sourceIdentifier[src] = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local saved = 0
    for identifier, seconds in pairs(sessionSeconds) do
        MySQL.Sync.execute(
            'INSERT INTO frosthub_playtime (identifier, seconds) VALUES (?, ?) ON DUPLICATE KEY UPDATE seconds = ?',
            { identifier, seconds, seconds }
        )
        saved = saved + 1
    end
    Config.Print(('saved playtime for %d players before stopping'):format(saved))
end)

RegisterNetEvent('frosthub_pausemenu:leaveServer', function()
    DropPlayer(source, 'You disconnected from the server.')
end)
