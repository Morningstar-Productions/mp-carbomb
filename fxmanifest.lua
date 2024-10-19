fx_version 'cerulean'
game 'gta5'

description 'Car Bomb Script for QBCore and QBox'
author 'xViperAG'
version '1.1.0'

ox_lib 'locale'

client_scripts { 'client/cl_*.lua' }
server_scripts { 'server/sv_*.lua' }
shared_scripts { '@ox_lib/init.lua' }

files { 'shared/*.lua', 'locales/*.json' }

lua54 'yes'
use_experimental_fxv2_oal 'yes'

dependencies {
    'ox_inventory',
    'ox_target',
    'ox_lib',
}
