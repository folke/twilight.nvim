local config = require("twilight.config")
local view = require("twilight.view")

local M = {}

M.setup = config.setup
M.toggle = view.toggle
M.disable = view.disable
M.enable = view.enable

function M.reset()
  M.disable()
  require("plenary.reload").reload_module("twilight")
  require("twilight").enable()
end

return M
