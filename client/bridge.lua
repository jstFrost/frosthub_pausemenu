FrostBridge = { framework = 'unknown' }

local function detectFramework()
    if Config.Framework ~= 'auto' then
        FrostBridge.framework = Config.Framework
        return
    end

    if GetResourceState('es_extended') == 'started' then
        FrostBridge.framework = 'esx'
    elseif GetResourceState('qbx_core') == 'started' or GetResourceState('qbox') == 'started' then
        FrostBridge.framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        FrostBridge.framework = 'qb'
    else
        FrostBridge.framework = 'unknown'
    end
end

detectFramework()
Config.Debug_Print('client framework -> ' .. FrostBridge.framework)

function FrostBridge.FetchPlayer()
    local ok, data = pcall(function()
        return lib.callback.await('frosthub_pausemenu:getPlayer', false)
    end)

    if not ok or type(data) ~= 'table' then
        Config.Debug_Print('FetchPlayer failed or returned nothing')
        return {}
    end

    return data
end

function FrostBridge.GetStreetName()
    local coords = GetEntityCoords(PlayerPedId())
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    return streetName ~= '' and streetName or 'Unknown location'
end
