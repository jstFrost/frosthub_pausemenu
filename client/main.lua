FrostPause = { suppressed = true }

-- GTA's own pause menu is force-closed every frame so ESC lands on this
-- resource instead. Suppression is lifted only while we deliberately open one
-- of the native frontends, which would otherwise be closed the next frame.
CreateThread(function()
    while true do
        if FrostPause.suppressed then
            SetPauseMenuActive(false)
        end
        Wait(0)
    end
end)

-- Opens one of GTA's own frontends and restores suppression once the player
-- leaves it. A frontend that never reports a pause-menu state falls back to a
-- fixed window, so suppression can never stay off for the rest of the session.
function FrostPause.OpenNative(menuName, jumpToMap)
    FrostPause.suppressed = false
    ActivateFrontendMenu(GetHashKey(menuName), false, -1)

    if jumpToMap then
        local ready = GetGameTimer() + 5000
        while not IsFrontendReadyForControl() and GetGameTimer() < ready do Wait(0) end
        Wait(20)
        SetControlNormal(2, 201, 1.0)
    end

    local appears = GetGameTimer() + 3000
    while GetPauseMenuState() == 0 and GetGameTimer() < appears do Wait(50) end

    if GetPauseMenuState() ~= 0 then
        while GetPauseMenuState() ~= 0 do Wait(100) end
    else
        Wait(30000)
    end

    FrostPause.suppressed = true
end

local function resolveView()
    if not Config.Camera.enabled then return 'center' end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return 'center' end
    return 'side'
end

local function toggleFrostMenu()
    if FrostMenu.open then
        FrostMenu.Close()
        return
    end

    -- ESC reaches both the interface and this command on the same press:
    -- without the cooldown, closing the menu would reopen it immediately.
    if GetGameTimer() - FrostMenu.lastClosedAt < 250 then return end
    if Config.IsPlayerDead() then return end
    if GetPauseMenuState() ~= 0 or IsNuiFocused() then return end

    FrostMenu.Open(resolveView())
end

CreateThread(function()
    Locale.Report()
    RegisterKeyMapping(Config.Keybind.command, Config.Keybind.label, 'keyboard', Config.Keybind.defaultKey)
    RegisterCommand(Config.Keybind.command, toggleFrostMenu, false)
end)
