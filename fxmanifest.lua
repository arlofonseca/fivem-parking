fx_version "cerulean"
game "gta5"

name "bgarage"
author "BerkieB & Bebo"
description "Vehicle garage and management system for FiveM"
version "1.1.2"
repository "https://github.com/bebomusa/bgarage"

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
}

ox_libs {
	"locale",
}

client_scripts {
	"modules/bridge/**/client.lua",
	"client/*.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"modules/bridge/**/server.lua",
	"server/*.lua",
}

ui_page "web/dist/index.html"

files {
	"web/dist/index.html",
	"web/dist/**/*",
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
