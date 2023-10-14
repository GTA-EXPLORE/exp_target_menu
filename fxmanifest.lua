fx_version "adamant"
game "gta5"
lua54 'yes'

author 'EXPLORE, MilyonJames'
description 'https://www.gta-explore.com'

ui_page "client/ui/index.html"

client_scripts {
  "locales/*.lua",
  "config.lua",
  "client/*"
}

files {
  "client/ui/**/*"
}

escrow_ignore {
    "config.lua",
    "locales/*"
}