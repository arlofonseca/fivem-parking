fx_version "cerulean"
game "gta5"

name "bGarage"
author "BerkieB & bebomusa"
description "Vehicle garage, management, and persistence system for FiveM."
version "1.1.6"
repository "https://github.com/bebomusa/bGarage"
license "MIT"

shared_script "@ox_lib/init.lua"

ox_lib "locale"

client_scripts {
	"client/main.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
}

files {
	"locales/*.json",
	"config.lua",
	"modules/bridge/**/client.lua",
	"modules/bridge/**/server.lua",
	"server/db.lua",
	"modules/utils/client.lua",
}

dependencies {
	"/onesync",
	"/server:7290",
	"oxmysql",
	"ox_lib",
}

lua54 "yes"
use_experimental_fxv2_oal "yes"
