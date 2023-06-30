fx_version "cerulean"
game "gta5"

author "BerkieB & Money#2075"
description "Vehicle or garage management resource"

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
}

client_scripts {
	"client.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server.lua",
}

dependencies {
	"/onesync",
	"/server:5848",
	"oxmysql",
	"ox_lib",
	"ox_inventory",
}

lua54 "yes"
use_experimental_fxv2_oal "yes"
