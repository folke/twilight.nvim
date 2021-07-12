local view = require("twilight.view")

local M = {}

M.toggle = view.toggle
M.disable = view.disable
M.enable = view.enable

function M.reset()
	M.disable()
	require("plenary.reload").reload_module("twilight")
	require("twilight").enable()
end

return M
