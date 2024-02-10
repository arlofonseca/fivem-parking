fx_version "cerulean"
game "gta5"

name "bgarage"
author "BerkieB & Bebo"
description "Vehicle / garage management"
version "1.1.1"
repository "https://github.com/bebomusa/bgarage"

ui_page 'web/dist/index.html'

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
}

ox_libs {
	"locale",
}

client_scripts {
	"client/framework/*.lua",
	"client/utils.lua",
	"client/main.lua",
	"client/nui_callbacks.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/framework/*.lua",
	"server/main.lua",
}

files {
	'web/dist/index.html',
	'web/dist/**/*',
	"locales/*.json"
}

dependencies {
	"/onesync",
	"/server:6129",
	"oxmysql",
	"ox_lib",
}

lua54 "yes"
use_experimental_fxv2_oal "yes"
