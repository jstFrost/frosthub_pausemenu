ServerBridge = { framework = 'unknown' }

local ESXObject, QBObject = nil, nil

local function detectFramework()
    if Config.Framework ~= 'auto' then
        ServerBridge.framework = Config.Framework
        return
    end

    if GetResourceState('es_extended') == 'started' then
        ServerBridge.framework = 'esx'
    elseif GetResourceState('qbx_core') == 'started' or GetResourceState('qbox') == 'started' then
        ServerBridge.framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        ServerBridge.framework = 'qb'
    else
        ServerBridge.framework = 'unknown'
    end

    Config.Print('framework detected: ' .. ServerBridge.framework)
end

detectFramework()

CreateThread(function()
    if ServerBridge.framework == 'esx' then
        ESXObject = exports['es_extended']:getSharedObject()
    elseif ServerBridge.framework == 'qb' then
        QBObject = exports['qb-core']:GetCoreObject()
    end
end)

function ServerBridge.GetIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('^license:') then return id end
    end
    return GetPlayerIdentifiers(src)[1]
end

local function fromEsx(src)
    if not ESXObject then return nil end
    local xPlayer = ESXObject.GetPlayerFromId(src)
    if not xPlayer then return nil end
    local bankAccount = xPlayer.getAccount('bank')
    return {
        name = xPlayer.getName(),
        job  = xPlayer.getJob() and xPlayer.getJob().name or 'unemployed',
        cash = tonumber(xPlayer.getMoney()) or 0,
        bank = bankAccount and bankAccount.money or 0,
    }
end

local function fromQb(src)
    if not QBObject then return nil end
    local player = QBObject.Functions.GetPlayer(src)
    if not player then return nil end
    local data = player.PlayerData
    local firstName = data.charinfo and data.charinfo.firstname or ''
    local lastName = data.charinfo and data.charinfo.lastname or ''
    return {
        name = (firstName .. ' ' .. lastName):gsub('^%s+', ''):gsub('%s+$', ''),
        job  = data.job and data.job.label or 'unemployed',
        cash = data.money and data.money.cash or 0,
        bank = data.money and data.money.bank or 0,
    }
end

local function fromQbox(src)
    local ok, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
    if not ok or not player then return nil end
    local data = player.PlayerData
    local firstName = data.charinfo and data.charinfo.firstname or ''
    local lastName = data.charinfo and data.charinfo.lastname or ''
    return {
        name = (firstName .. ' ' .. lastName):gsub('^%s+', ''):gsub('%s+$', ''),
        job  = data.job and data.job.label or 'unemployed',
        cash = data.money and data.money.cash or 0,
        bank = data.money and data.money.bank or 0,
    }
end

function ServerBridge.GetRawPlayer(src)
    if ServerBridge.framework == 'esx' then return fromEsx(src) end
    if ServerBridge.framework == 'qb' then return fromQb(src) end
    if ServerBridge.framework == 'qbox' then return fromQbox(src) end
    return nil
end
