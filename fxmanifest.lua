fx_version 'cerulean'
game 'gta5'

author 'UnixLib'
version '1.0.0'
description 'Unix-Winch - Vehicle Winch System'

lua54 'yes'

dependencies {
    'ox_lib',
    'unix_lib',
}

shared_scripts {
    '@unix_lib/shared/**/*.lua',
    'config.lua',
}

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua',
}

files {
    'locales/*.json',
}
