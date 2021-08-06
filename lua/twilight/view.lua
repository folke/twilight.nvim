local config = require("twilight.config")

local M = {}

local ns = vim.api.nvim_create_namespace("twilight")

M.enabled = false

function M.enable()
  if not M.enabled then
    config.colors()
    M.enabled = true
    -- HACK: use defer_fn since TreeSitter is doing something that breaks the dimmers
    vim.cmd([[
        augroup Twilight
          autocmd!
          autocmd BufWritePost,CursorMoved,CursorMovedI,WinScrolled * lua require("twilight.view").update()
          autocmd WinEnter * lua require("twilight.view").on_win_enter()
          autocmd BufWritePost * lua vim.defer_fn(function()require("twilight.view").update()end, 0)
          autocmd ColorScheme * lua require("twilight.config").colors()
        augroup end]])
    M.started = true
    M.on_win_enter()
  end
end

function M.on_win_enter()
  local current = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= current then
      if config.options.dimming.inactive then
        local from, to = M.get_visible(win)
        for i = from, to do
          M.dim(vim.api.nvim_win_get_buf(win), i)
        end
      else
        M.update(win)
      end
    end
  end
  M.update()
end

function M.disable()
  if M.enabled then
    M.enabled = false
    pcall(vim.cmd, "autocmd! Twilight")
    pcall(vim.cmd, "augroup! Twilight")
    for _, buf in pairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        M.clear(buf)
      end
    end
  end
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.clear(buf, from, to)
  from = from or 0
  to = to or -1
  if from < 0 then
    from = 0
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, from, to)
end

-- TODO: fooo
function M.dim(buf, lnum)
  -- use extmarks directly so we can set the priority
  -- do a pcall instead to prevent spurious errors at the end of the doc
  pcall(vim.api.nvim_buf_set_extmark, buf, ns, lnum, 0, {
    end_line = lnum + 1,
    end_col = 0,
    hl_group = "Twilight",
    hl_eol = true,
    priority = 10000,
  })
  -- vim.api.nvim_buf_add_highlight(buf, ns, "Twilight", lnum, 0, -1)
end

function M.range(node)
  local from, _, to, _ = node:range()
  return from, to
end

function M.get_node(buf, line)
  local lines = vim.api.nvim_buf_get_lines(buf, line, line + 1, false)
  local col = lines[1] and (#lines[1] - 1) or 0
  if col < 0 then
    col = 0
  end

  local parser = vim.treesitter.get_parser(buf)
  local ret
  parser:for_each_tree(function(tree)
    if ret then
      return
    end
    local root = tree:root()
    if root then
      local node = root:descendant_for_range(line, col, line, col)
      local parent = node:parent()
      while parent and (parent:start() == line or parent:end_() == line) do
        node = parent
        parent = node:parent()
      end
      if node and node ~= root then
        ret = node
      end
    end
  end)
  return ret
end

function M.is_empty(buf, line)
  local lines = vim.api.nvim_buf_get_lines(buf, line, line + 1, false)
  if vim.fn.trim(lines[1]) == "" then
    return true
  end
  return false
end

function M.expand(buf, from, to, line)
  if line < 1 then
    return from, to
  end
  if M.is_empty(buf, line) then
    return math.min(from, line), math.max(to, line)
  end
  local node = M.get_node(buf, line)
  if not node then
    return from, to
  end
  local f, t = M.range(node)
  if f < from then
    from = f
  end
  if t > to then
    to = t
  end
  return from, to, node
end

function M.get_expand_root(node, opts)
  opts = opts or {}
  local root
  while node do
    if config.expand[node:type()] then
      if opts.first then
        return node
      end
      root = node
    end
    node = node:parent()
  end
  return root
end

function M.get_context(buf, line)
  if config.options.treesitter and pcall(vim.treesitter.get_parser, buf) then
    local node = M.get_node(buf, line)
    local root = M.get_expand_root(node)
    if root then
      local from, to = M.range(root)
      return from + 1, to + 2
    end
    local from, to = M.expand(buf, line, line, line)

    while to - from < config.options.context do
      local pf, pt, pnode = M.expand(buf, from, to, from - 1)
      local nf, nt, nnode = M.expand(buf, from, to, to + 1)

      local mp = math.max(line - pf, pt - line)
      local mn = math.max(line - nf, nt - line)

      if (mp < mn) and not (from == pf and to == pt) then
        from = pf
        to = pt
        if pnode and M.get_expand_root(pnode) then
          break
        end
      elseif not (from == nf and to == nt) then
        from = nf
        to = nt
        if nnode and M.get_expand_root(nnode) then
          break
        end
      else
        break
      end
    end

    return from + 1, to + 2
  end

  local from = line - math.floor(config.options.context / 2)
  local to = line + math.floor(config.options.context / 2)

  local lcount = vim.api.nvim_buf_line_count(buf)

  if to > lcount then
    to = lcount
  end
  if from < 1 then
    from = 1
  end
  while from > 0 and not M.is_empty(buf, from) do
    from = from - 1
  end

  while to < lcount and not M.is_empty(buf, to) do
    to = to + 1
  end

  return from + 1, to + 2
end

function M.is_valid_buf(buf)
  -- Skip special buffers
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if buftype ~= "" then
    return false
  end
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  if vim.tbl_contains(config.options.exclude, filetype) then
    return false
  end
  return true
end

function M.update(win)
  win = win or vim.api.nvim_get_current_win()

  if not M.enabled or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not M.is_valid_buf(buf) then
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(win)
  local from, to = M.get_context(buf, cursor[1] - 1)

  local dimmers = {}
  M.focus(win, from, to, dimmers)

  for _, other in ipairs(vim.api.nvim_list_wins()) do
    if other ~= win and vim.api.nvim_win_get_buf(other) == buf then
      M.focus(other, from, to, dimmers)
    end
  end

  M.clear(buf, from - 1, to - 1)

  for lnum, _ in pairs(dimmers) do
    M.dim(buf, lnum - 1)
  end
end

function M.get_visible(win)
  local info = vim.fn.getwininfo(win)
  return info[1].topline, info[1].botline + 1
end

function M.focus(win, from, to, dimmers)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local topline, botline = M.get_visible(win)

  for l = topline, botline do
    if l < from or l >= to then
      dimmers[l] = true
    end
  end
end

return M
