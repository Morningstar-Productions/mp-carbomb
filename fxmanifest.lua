fx_version 'cerulean'
game 'gta5'

description 'Car Bomb Script for QBCore and QBox'
author 'xViperAG'
version '1.0.0'

--modules { 'qbx_core:utils', 'qbx_core:playerdata'} -- Uncomment if using qbx_core

client_scripts {
    'client/cl_*.lua'
}

server_scripts {
    'server/sv_*.lua'
}

shared_scripts { 
    'shared/**/*',
    '@ox_lib/init.lua',
    -- '@qbx_core/import.lua' -- Uncomment if using qbx_core
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

dependencies {
    'qb-core',
    'ox_inventory',
    'ox_target',
    'ox_lib',
    -- 'qbx_core'
}
