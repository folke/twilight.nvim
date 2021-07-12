local util = require("twilight.util")
local M = {}

--- @class TwilightOptions
local defaults = {
  dimming = {
    alpha = 0.25, -- amount of dimming
    -- we try to get the foreground from the highlight groups or fallback color
    color = { "Normal", "#ffffff" },
  },
  context = 10, -- amount of lines we will try to show arounc the current line
  -- treesitter is used to automatically expand the visible text,
  -- but you can further control the types of nodes that should always be fully expanded
  expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
    "function",
    "method",
    "table",
    "if_statement",
  },
  exclude = {}, -- exclude these filetypes
}

--- @type TwilightOptions
M.options = {}
M.types = {}
M.expand = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  for _, value in pairs(M.options.expand) do
    M.expand[value] = true
  end
  local fg = "#ffffff"
  for _, color in pairs(M.options.dimming.color) do
    if color:sub(1, 1) == "#" then
      fg = color
      break
    end
    local hl = util.get_hl(color)
    if hl and hl.foreground then
      fg = hl.foreground
      break
    end
  end
  local normal = util.get_hl("Normal")
  local dimmed = util.blend(fg, normal.background, M.options.dimming.alpha)
  vim.cmd("highlight! def Twilight guifg=" .. dimmed)
end

M.setup()

return M
