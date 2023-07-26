fx_version "cerulean"
game "gta5"

name "vgarage"
author "BerkieB & Bebo"
description "Vehicle / garage management resource"
version "1.0.4"
repository "https://github.com/bebomusa/vgarage"

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	"init.lua",
}

client_scripts { 
	"modules/**/client.lua",
	"client.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"modules/**/server.lua",
	"server.lua",
}

files {
	"locales/*.json",
}

dependencies {
	"/onesync",
	"/server:6129",
	"oxmysql",
	"ox_lib",
}

lua54 "yes"
use_experimental_fxv2_oal "yes"