fx_version "cerulean"
game "gta5"

name "bgarage"
author "BerkieB & Bebo"
description "Vehicle garage and management system for FiveM"
version "1.1.4"
repository "https://github.com/bebomusa/bgarage"

shared_script "@ox_lib/init.lua"

ox_libs {
	"locale",
}

client_scripts {
	"client/main.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
}

ui_page "web/dist/index.html"

files {
	"web/dist/index.html",
	"web/dist/**/*",
	"locales/*.json",
	"config.lua",
	"modules/bridge/**/client.lua",
	"modules/bridge/**/server.lua",
	"modules/interface/client.lua",
	"modules/utils/client.lua",
}

dependencies {
	"/onesync",
	"/server:6129",
	"oxmysql",
	"ox_lib",
}

lua54 "yes"
use_experimental_fxv2_oal "yes"
