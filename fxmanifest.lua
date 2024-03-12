fx_version "cerulean"
game "gta5"

name "bgarage"
author "BerkieB & Bebo"
description "Vehicle garage and management system for FiveM"
repository "https://github.com/bebomusa/bgarage"
version "1.1.6"

shared_script "@ox_lib/init.lua"

ox_lib "locale"

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
	"client/framework/*.lua",
	"server/framework/*.lua",
	"client/utils.lua",
	"server/db.lua",
}

dependencies {
	"/onesync",
	"/server:7290",
	"oxmysql",
	"ox_lib",
}

lua54 "yes"
use_experimental_fxv2_oal "yes"
