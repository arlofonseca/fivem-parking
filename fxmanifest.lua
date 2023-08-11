fx_version "cerulean"
game "gta5"

name "bgarage"
author "BerkieB & Bebo"
description "Vehicle / garage management"
version "1.0.6"
repository "https://github.com/bebomusa/bgarage"

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	"init.lua",
}

client_scripts {
	"modules/**/**.lua",
	"client.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"modules/**/**.lua",
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