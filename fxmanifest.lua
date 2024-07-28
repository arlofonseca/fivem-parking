fx_version 'cerulean'
game 'gta5'

name 'bGarage'
author 'BerkieB & shifu614'
description 'Vehicle garage, management, and persistence system for FiveM.'
version '1.2.1'
repository 'https://github.com/shifu614/bGarage'
license 'MIT'

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
	'client/class/*.lua',
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
