CreateThread(function()
    while true do
        SetPauseMenuActive(false)
        Wait(0)
    end
end)

local function openFrostMenu()
    if Config.IsPlayerDead() then return end
    if GetPauseMenuState() ~= 0 or IsNuiFocused() then return end

    local view = Config.Camera.enabled and 'side' or 'center'
    FrostMenu.Open(view)
end

CreateThread(function()
    Locale.Report()
    RegisterKeyMapping(Config.Keybind.command, Config.Keybind.label, 'keyboard', Config.Keybind.defaultKey)
    RegisterCommand(Config.Keybind.command, openFrostMenu, false)
end)
