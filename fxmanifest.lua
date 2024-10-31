fx_version 'cerulean'
game 'gta5'

name 'fivem-parking'
author 'arlofonseca & BerkieB'
description 'Vehicle garage for FiveM.'
version '1.2.3'
repository 'https://github.com/arlofonseca/fivem-parking'
license 'MIT'

server_scripts {
  'dist/server/**/*',
}

dependencies {
  '/server:7290',
  '/onesync',
  'oxmysql',
  'ox_lib',
  'ox_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
