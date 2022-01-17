local util = require("twilight.util")
local M = {}

--- @class TwilightOptions
local defaults = {
  dimming = {
    alpha = 0.25, -- amount of dimming
    -- we try to get the foreground from the highlight groups or fallback color
    color = { "Normal", "#ffffff" },
    inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
  },
  context = 10, -- amount of lines we will try to show arounc the current line
  node_context = 0, -- amount of extra nodes to show. Only node types mention in expand are considered
  treesitter = true, -- use treesitter when available for the filetype
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
end

function M.colors()
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
  local bg = (normal and normal.background) or "#000000"
  local dimmed = util.blend(fg, bg, M.options.dimming.alpha)
  vim.cmd("highlight! def Twilight guifg=" .. dimmed .. " guibg=" .. bg)
end

M.setup()

return M
