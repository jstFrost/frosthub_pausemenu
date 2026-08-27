fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'frosthub_pausemenu'
description 'Frost Hub - in-game pause menu (camera side-view, player card, quick links)'
author 'Frost Hub'
version '1.0.0'

shared_scripts {
    'config/settings.lua',
    'config/locales.lua',
    'locales/*.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/camera.lua',
    'client/nui.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'server/main.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}
