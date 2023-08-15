fx_version 'cerulean'
game 'gta5'
lua54 'yes' 

author "Terminator"
description "Staff menu, gebouwd voor Eindhoven City"
version "1.0.0"

shared_script '@es_extended/imports.lua'

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}