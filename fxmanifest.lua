fx_version 'cerulean'
game 'gta5'

author 'mrshortyno'
description 'Multijob and boss menu for ESX, QBCORE and QBOX'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
	'@oxmysql/lib/MySQL.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

files {
	'locales/*.json',
}