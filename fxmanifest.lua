fx_version 'cerulean'
game 'gta5'

name 'fivem-parking'
author 'arlofonseca & BerkieB'
description 'Vehicle garage for FiveM.'
version '1.2.4'
repository 'https://github.com/arlofonseca/fivem-parking'
license 'MIT'

client_scripts {
  'dist/client/*.js',
}
server_scripts {
  'dist/server/*.js',
}

dependencies {
  '/server:12913',
  '/onesync',
  'ox_lib',
  'ox_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
node_version '22'
