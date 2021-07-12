if !has('nvim-0.5')
  echohl WarningMsg
  echom "Twilight needs Neovim >= 0.5"
  echohl None
  finish
endif

command! Twilight lua require("twilight").toggle()
command! TwilightEnable lua require("twilight").enable()
command! TwilightDisable lua require("twilight").disable()
