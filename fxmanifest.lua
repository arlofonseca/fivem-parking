fx_version 'cerulean'
game 'gta5'

name 'fivem-parking'
author 'arlofonseca & BerkieB'
description 'Vehicle garage, management, and persistence system for FiveM.'
version '1.2.2'
repository 'https://github.com/arlofonseca/fivem-parking'

shared_script '@ox_lib/init.lua'

ox_lib 'locale'

client_scripts {
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'init.lua',
	'server/main.lua',
}

files {
	'client/framework/*.lua',
	'client/utils/*.lua',
	'config/client.lua',
	'config/shared.lua',
	'locales/*.json',
}

dependencies {
	'/onesync',
	'/server:7290',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
