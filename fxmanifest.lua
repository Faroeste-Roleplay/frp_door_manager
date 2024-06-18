fx_version 'adamant'
game 'common'

shared_scripts {
	'@frp_lib/library/linker.lua',
    'shared/eDoorState.lua',

    'shared/Main.lua',

    'shared/Database.lua',
    'shared/DatabaseItems.lua',
}

client_scripts {
    'client/Utils.lua',

    'client/Main.lua'
}

server_script 'server/Main.lua'

lua54 'yes'