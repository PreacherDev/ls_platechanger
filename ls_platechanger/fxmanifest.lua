fx_version 'cerulean'
game       'gta5'
lua54      'yes'
author     'Life Scripts - Preacher'
version    '1.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
