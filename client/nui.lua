FrostMenu = {
    open = false,
    lastView = nil,
    lastClosedAt = 0,
}

local heldProp = nil
local animRunning = false
local refreshToken = 0

local function playHeldPropAnim()
    if animRunning or not Config.Animation.enabled then return end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end

    local anim = Config.Animation

    RequestAnimDict(anim.dict)
    local dictTimeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(anim.dict) do
        Wait(0)
        if GetGameTimer() > dictTimeout then
            Config.Debug_Print('timed out loading anim dict: ' .. anim.dict)
            return
        end
    end

    local model = GetHashKey(anim.prop)
    RequestModel(model)
    local modelTimeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() > modelTimeout then
            Config.Debug_Print('timed out loading prop model: ' .. anim.prop)
            return
        end
    end

    TaskPlayAnim(ped, anim.dict, anim.anim, 2.0, 2.0, -1, 51, 0, false, false, false)

    local coords = GetEntityCoords(ped)
    heldProp = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, false, false)
    AttachEntityToEntity(
        heldProp, ped, GetPedBoneIndex(ped, anim.propBone),
        0.0, -0.03, 0.0, 20.0, -90.0, 0.0,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(model)
    animRunning = true
end

local function stopHeldPropAnim()
    -- Deleted unconditionally: another resource clearing the ped's tasks used
    -- to leave the prop behind, floating in the world.
    if heldProp then
        if DoesEntityExist(heldProp) then DeleteEntity(heldProp) end
        heldProp = nil
    end

    if not animRunning then return end

    local ped = PlayerPedId()
    local anim = Config.Animation
    if IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3) then
        ClearPedTasks(ped)
    end
    RemoveAnimDict(anim.dict)
    animRunning = false
end

local function buildPayload(view, player)
    return {
        open       = true,
        view       = view,
        theme      = Config.ResolveTheme(),
        currency   = Config.ResolveCurrency(),
        locale     = Locale.export(),
        links      = Config.Links,
        serverName = Config.ServerName,
        player     = player or {},
        street     = FrostBridge.GetStreetName(),
    }
end

local function guardLoopWhileOpen()
    CreateThread(function()
        while FrostMenu.open do
            DisableControlAction(0, 200, true)
            if Config.IsPlayerDead() then
                FrostMenu.Close()
                return
            end
            Wait(0)
        end
    end)
end

-- The token makes a reopen invalidate the previous loop straight away, instead
-- of leaving it to expire on its own an entire minute later.
local function refreshLoopWhileOpen()
    refreshToken = refreshToken + 1
    local token = refreshToken

    CreateThread(function()
        while true do
            Wait(60000)
            if not FrostMenu.open or token ~= refreshToken then return end

            local player = FrostBridge.FetchPlayer()
            if not FrostMenu.open or token ~= refreshToken then return end

            SendNUIMessage(buildPayload(FrostMenu.lastView, player))
        end
    end)
end

function FrostMenu.Open(view)
    if FrostMenu.open then return end

    -- Claimed before the round trip: fetching the player yields, and a second
    -- keypress inside that window used to open the menu twice.
    FrostMenu.open = true
    FrostMenu.lastView = view

    local player = FrostBridge.FetchPlayer()
    if not FrostMenu.open then return end

    SetNuiFocus(true, true)
    SendNUIMessage(buildPayload(view, player))
    guardLoopWhileOpen()
    refreshLoopWhileOpen()

    if view == 'side' then
        if Config.Animation.enabled then playHeldPropAnim() end
        if Config.Camera.enabled then FrostCam.Start() end
    end
end

function FrostMenu.Close()
    if not FrostMenu.open then return end

    FrostMenu.open = false
    FrostMenu.lastClosedAt = GetGameTimer()
    refreshToken = refreshToken + 1

    SetNuiFocus(false, false)
    SendNUIMessage({ open = false })
    stopHeldPropAnim()
    if FrostCam.Exists() then FrostCam.Stop() end
end

-- Without this, restarting the resource with the menu open leaves the player
-- stuck behind a focused NUI and a scripted camera until they reconnect.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    SetNuiFocus(false, false)

    if heldProp and DoesEntityExist(heldProp) then DeleteEntity(heldProp) end
    if animRunning then ClearPedTasks(PlayerPedId()) end
    if FrostCam.Exists() then FrostCam.Stop(true) end
end)

RegisterNuiCallback('close', function(_, cb)
    FrostMenu.Close()
    cb('ok')
end)

RegisterNuiCallback('openMap', function(_, cb)
    FrostMenu.Close()
    cb('ok')
    Wait(300)
    FrostPause.OpenNative('FE_MENU_VERSION_MP_PAUSE', true)
end)

RegisterNuiCallback('openSettings', function(_, cb)
    FrostMenu.Close()
    cb('ok')
    Wait(300)
    FrostPause.OpenNative('FE_MENU_VERSION_LANDING_MENU', false)
end)

RegisterNuiCallback('leave', function(_, cb)
    FrostMenu.Close()
    cb('ok')
    Wait(300)
    TriggerServerEvent('frosthub_pausemenu:leaveServer')
end)
