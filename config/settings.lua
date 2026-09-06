--[[
    Frost Hub - Pause Menu
    Everything you're likely to change lives in this file.
]]

Config = {}

-- "auto" detects es_extended / qb-core / qbx_core on start.
-- Force it with "esx", "qb" or "qbox" if autodetect picks the wrong one.
Config.Framework = 'auto'

-- Name shown next to the logo at the top of the menu.
Config.ServerName = 'FROST HUB'

-- Interface language: en | it | es | fr
Config.Locale = 'en'

-- Prints extra information in the server/client console.
Config.Debug = false

-- Money formatting in the Assets panel.
--   locale   -> number format. 'auto' follows Config.Locale
--               (en -> 1,234.00 | it/es -> 1.234,00 | fr -> 1 234,00)
--   symbol   -> shown before the amount
--   decimals -> decimal digits
Config.Currency = {
    locale   = 'auto',
    symbol   = '$',
    decimals = 2,
}

Config.Keybind = {
    command = 'frosthubmenu',
    defaultKey = 'ESCAPE',
    label = 'Open Pause Menu',
}

-- How the "Affiliation" row in the Identity panel is filled in. Accepts:
--   false            -> the field is hidden
--   "qbcore"         -> reads PlayerData.gang.label from qb-core
--   "qbox"           -> reads PlayerData.gang.label from qbx_core
--   "rcore_gangs"    -> exports.rcore_gangs:GetPlayerGang
--   function(source) -> return the gang name yourself
Config.GangResolver = false

-- Scripted camera that frames the player from the side while the menu is open.
-- Set enabled = false for a plain centered overlay instead.
Config.Camera = {
    enabled = true,
    distance = 1.8,
    height = 0.6,
    transitionMs = 1000,
}

-- Animation played while the menu is open (the character reads a map).
Config.Animation = {
    enabled = true,
    dict = 'amb@world_human_tourist_map@male@base',
    anim = 'base',
    prop = 'prop_tourist_map_01',
    propBone = 28422,
}

-- Color preset used by the interface, from Config.Themes below.
-- Same preset names and accent colors as the Frost Hub loading screen, so
-- setting the same name in both resources makes them match.
Config.Theme = 'lime' -- lime | cyan | crimson | violet | amber | ice

Config.Themes = {
    -- Lime green, street racing style (default)
    lime = {
        accent        = '#d4e83a',
        accentSoft    = 'rgba(212, 232, 58, 0.15)',
        panelBg       = 'rgba(10, 12, 10, 0.72)',
        panelBorder   = 'rgba(212, 232, 58, 0.25)',
        textPrimary   = '#f2f4ec',
        textSecondary = 'rgba(242, 244, 236, 0.6)',
    },
    -- Cyan, cold tech / cyberpunk style
    cyan = {
        accent        = '#3ad9e8',
        accentSoft    = 'rgba(58, 217, 232, 0.15)',
        panelBg       = 'rgba(8, 14, 18, 0.72)',
        panelBorder   = 'rgba(58, 217, 232, 0.25)',
        textPrimary   = '#ecf7fa',
        textSecondary = 'rgba(236, 247, 250, 0.6)',
    },
    -- Red, aggressive / mafia RP style
    crimson = {
        accent        = '#ff3b4e',
        accentSoft    = 'rgba(255, 59, 78, 0.15)',
        panelBg       = 'rgba(16, 8, 10, 0.72)',
        panelBorder   = 'rgba(255, 59, 78, 0.25)',
        textPrimary   = '#faecee',
        textSecondary = 'rgba(250, 236, 238, 0.6)',
    },
    -- Purple, nightlife / nightclub style
    violet = {
        accent        = '#a56bff',
        accentSoft    = 'rgba(165, 107, 255, 0.16)',
        panelBg       = 'rgba(14, 10, 20, 0.72)',
        panelBorder   = 'rgba(165, 107, 255, 0.25)',
        textPrimary   = '#f1ecfa',
        textSecondary = 'rgba(241, 236, 250, 0.6)',
    },
    -- Amber, warm style / desert, trucking, western
    amber = {
        accent        = '#ffab2e',
        accentSoft    = 'rgba(255, 171, 46, 0.15)',
        panelBg       = 'rgba(18, 13, 8, 0.72)',
        panelBorder   = 'rgba(255, 171, 46, 0.25)',
        textPrimary   = '#faf2e8',
        textSecondary = 'rgba(250, 242, 232, 0.6)',
    },
    -- Icy white, clean and minimal style
    ice = {
        accent        = '#dceaf5',
        accentSoft    = 'rgba(220, 234, 245, 0.14)',
        panelBg       = 'rgba(12, 14, 16, 0.72)',
        panelBorder   = 'rgba(220, 234, 245, 0.22)',
        textPrimary   = '#f4f7fa',
        textSecondary = 'rgba(244, 247, 250, 0.6)',
    },
}

-- Anything set here overrides the preset chosen above, so you can start from
-- a preset and change only what you need, e.g. { accent = "#00ff88" }.
Config.ThemeOverride = {}

Config.Links = {
    discord = 'https://discord.gg/eMpPD5GMpk',
    store   = 'https://store.tebex.io/frosthub',
}

function Config.ResolveTheme()
    local preset = Config.Themes[Config.Theme] or Config.Themes.lime
    local resolved = {}
    for key, value in pairs(preset) do
        resolved[key] = value
    end
    for key, value in pairs(Config.ThemeOverride or {}) do
        resolved[key] = value
    end
    return resolved
end

local CURRENCY_LOCALES = {
    en = 'en-US',
    it = 'it-IT',
    es = 'es-ES',
    fr = 'fr-FR',
}

function Config.ResolveCurrency()
    local currency = Config.Currency or {}
    local locale = currency.locale

    if not locale or locale == 'auto' then
        locale = CURRENCY_LOCALES[Config.Locale] or 'en-US'
    end

    local decimals = currency.decimals
    if type(decimals) ~= 'number' then decimals = 2 end

    return {
        locale   = locale,
        symbol   = currency.symbol or '$',
        decimals = decimals,
    }
end

function Config.IsPlayerDead()
    return IsEntityDead(PlayerPedId())
end

local function Log(prefix, message)
    print(('[FrostHub PauseMenu] [%s] %s'):format(prefix, message))
end

function Config.Print(message) Log('info', message) end

function Config.Debug_Print(message)
    if Config.Debug then Log('debug', tostring(message)) end
end
