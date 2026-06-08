return function(map)
  local function truncate(text, max_len)
    max_len = max_len or 50
    local single_line = text:gsub("\n", "\\n")
    if #single_line > max_len then
      return single_line:sub(1, max_len) .. "..."
    end
    return single_line
  end

  -- Yank to system clipboard
  map("v", "<leader>yy", function()
    vim.cmd('normal! "+y')
    print("Yanked: " .. truncate(vim.fn.getreg("+")))
  end, "Copy lines")

  map("n", "<leader>yy", function()
    vim.cmd('normal! "+yy')
    print("Yanked: " .. truncate(vim.fn.getreg("+")))
  end, "Copy line")

  -- Copy git remote permalink to system clipboard
  local gitlinker = require("gitlinker")
  map("n", "<leader>yg", function()
    gitlinker.get_buf_range_url("n")
  end, "Copy git permalink")
  map("v", "<leader>yg", function()
    gitlinker.get_buf_range_url("v")
  end, "Copy git permalink (selection)")

  -- Copy file path to clipboard
  map("n", "<leader>yf", function()
    local filepath = vim.fn.expand("%")
    vim.fn.setreg("+", filepath)
    print("Copied: " .. filepath)
  end, "Copy file path")

  -- Copy file:line to clipboard
  map("n", "<leader>yl", function()
    local file_line = vim.fn.expand("%") .. ":" .. vim.fn.line(".")
    vim.fn.setreg("+", file_line)
    print("Copied: " .. file_line)
  end, "Copy file:line")

  map("v", "<leader>yl", function()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    local file_range = vim.fn.expand("%") .. ":" .. start_line .. "-" .. end_line
    vim.fn.setreg("+", file_range)
    print("Copied: " .. file_range)
  end, "Copy file:line-range")

  -- Paste from system clipboard
  map({ "n", "v" }, "<leader>p", '"+p', "Paste from system clipboard")
  map({ "n", "v" }, "<leader>P", '"+P', "Paste before from system clipboard")
end
