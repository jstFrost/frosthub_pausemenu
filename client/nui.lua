FrostMenu = {
    open = false,
    lastView = nil,
}

local heldProp = nil
local animRunning = false

local function playHeldPropAnim()
    if animRunning or not Config.Animation.enabled then return end

    local ped = PlayerPedId()
    local anim = Config.Animation

    RequestAnimDict(anim.dict)
    while not HasAnimDictLoaded(anim.dict) do Wait(0) end

    local model = GetHashKey(anim.prop)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() > timeout then
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

    animRunning = true
end

local function stopHeldPropAnim()
    local ped = PlayerPedId()
    local anim = Config.Animation
    if heldProp and IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3) then
        DeleteEntity(heldProp)
        ClearPedTasks(ped)
    end
    heldProp = nil
    animRunning = false
end

local function buildPayload(view, player)
    return {
        open       = true,
        view       = view,
        theme      = Config.ResolveTheme(),
        locale     = Locale.export(),
        links      = Config.Links,
        serverName = Config.ServerName,
        player     = player or {},
        street     = FrostBridge.GetStreetName(),
    }
end

local function lockControlsWhileOpen()
    CreateThread(function()
        repeat
            DisableControlAction(0, 200, true)
            Wait(0)
        until not FrostMenu.open
    end)
end

local function refreshLoopWhileOpen()
    CreateThread(function()
        while FrostMenu.open do
            Wait(60000)
            if FrostMenu.open then
                local player = FrostBridge.FetchPlayer()
                SendNUIMessage(buildPayload(FrostMenu.lastView, player))
            end
        end
    end)
end

function FrostMenu.Open(view)
    local player = FrostBridge.FetchPlayer()

    FrostMenu.open = true
    FrostMenu.lastView = view

    SetNuiFocus(true, true)
    SendNUIMessage(buildPayload(view, player))
    lockControlsWhileOpen()
    refreshLoopWhileOpen()

    if view == 'side' then
        if Config.Animation.enabled then playHeldPropAnim() end
        if Config.Camera.enabled then FrostCam.Start() end
    end
end

function FrostMenu.Close()
    FrostMenu.open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ open = false })
    stopHeldPropAnim()
    if FrostCam.Exists() then FrostCam.Stop() end
end

RegisterNuiCallback('close', function(_, cb)
    FrostMenu.Close()
    cb('ok')
end)

RegisterNuiCallback('openMap', function(_, cb)
    FrostMenu.Close()
    cb('ok')
    Wait(300)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'), false, -1)
    while not IsFrontendReadyForControl() do Wait(10) end
    Wait(20)
    SetControlNormal(2, 201, 1.0)
end)

RegisterNuiCallback('openSettings', function(_, cb)
    FrostMenu.Close()
    cb('ok')
    Wait(300)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'), false, -1)
end)

RegisterNuiCallback('leave', function(_, cb)
    FrostMenu.Close()
    cb('ok')
    Wait(300)
    TriggerServerEvent('frosthub_pausemenu:leaveServer')
end)
