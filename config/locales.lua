--[[
    Frost Hub - Pause Menu
    Translation helper. Language files live in locales/ and register
    themselves into Locale.packs. To add a language, copy locales/en.lua,
    rename it and set Config.Locale to the new code.
]]

Locale = {
    packs = {},
}

function Locale.export()
    return Locale.packs[Config.Locale] or Locale.packs.en or {}
end

function Locale.Report()
    local available = {}
    for code in pairs(Locale.packs) do available[#available + 1] = code end
    Config.Print(('locale "%s" active - packs loaded: %s'):format(Config.Locale, table.concat(available, ', ')))
    if not Locale.packs[Config.Locale] then
        Config.Print(('locale "%s" not found, falling back to "en"'):format(Config.Locale))
    end
end
