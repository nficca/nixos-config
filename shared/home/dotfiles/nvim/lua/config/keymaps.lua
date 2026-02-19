-- WhichKey shows you available keybindings as a popup
local which_key = require("which-key")
vim.keymap.set("n", "<leader>?", function()
  which_key.show({ global = false })
end, { desc = "Show local keymaps" })

-- Language server keymaps --
which_key.add({ "<leader>l", group = "Language server tools" })

vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Jump to definition" })
vim.keymap.set("n", "<leader>lf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format code" })
vim.keymap.set("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

which_key.add({ "<leader>lx", group = "Diagnostics" })

-- Toggles diagnostics between:
--   - separate lines (virtual_lines)
--   - inline text (virtual_text)
--   - none
local toggle_diagnostics = function()
  local cfg = vim.diagnostic.config()

  if not cfg then
    print("Could not find diagnostic config")
    return
  end

  local enable_lines = false
  local enable_text = false

  if not (cfg.virtual_lines or cfg.virtual_text) then
    enable_lines = false
    enable_text = true
  elseif cfg.virtual_lines then
    enable_lines = false
    enable_text = true
  end

  vim.diagnostic.config({ virtual_lines = enable_lines })
  vim.diagnostic.config({ virtual_text = enable_text })
end

vim.keymap.set("n", "<leader>lxt", toggle_diagnostics, { desc = "Toggle inline diagnostics" })
vim.keymap.set("n", "<leader>lxx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble diagnostics" })

-- Hoversplit allow for LSP hover text in a split window
-- Since it's LSP related, its keymaps can share the same prefix
local hoversplit = require("hoversplit")
vim.keymap.set("n", "<leader>lh", hoversplit.split_remain_focused, { desc = "Toggle LSP split (horizontal)" })


-- Neogit keymaps --
-- which_key.add({ "<leader>g", group = "Git" })
vim.keymap.set("n", "<leader>g", "<cmd>Neogit<CR>", { desc = "Git" })

-- Oil keymaps (file tree editor) --
local function oil_open_float()
  require("oil").open_float(nil, { preview = { vertical = true } }, function()
    print("Opened Oil. Use g? to see available keymaps.")
  end)
end

vim.keymap.set("n", "<leader>o", oil_open_float, { desc = "Open Oil (file tree editor)" })

-- Telescope keymaps --
which_key.add({ "<leader>f", group = "Find things" })

local telescope = require("telescope.builtin")

local function telescope_keymap(km, fn, desc)
  vim.keymap.set("n", "<leader>" .. km, fn, { desc = desc })
end

telescope_keymap("ff", function()
  telescope.find_files({
    find_command = { "rg", "--files", "--sortr=accessed" }
  })
end, "Find files (sort by modified)")
telescope_keymap("ft", telescope.live_grep, "Find text (regex)")
telescope_keymap("fT", function()
  telescope.live_grep({
    additional_args = function(_opts)
      return { "--fixed-strings" }
    end,
  })
end, "Find text (literal)")
telescope_keymap("fb", function() telescope.buffers({ sort_lastused = true }) end, "Find opened buffers")
telescope_keymap("fr", telescope.lsp_references, "Find references of symbol")
telescope_keymap("fg", telescope.git_status, "Find git changes")
telescope_keymap("fs", telescope.lsp_dynamic_workspace_symbols, "Find symbols")
telescope_keymap("fj", telescope.jumplist, "Find jumplist entries")

telescope_keymap("F", telescope.resume, "Resume previous search")

-- Clipboard and Register keymaps --

-- Yank keymaps --
which_key.add({ "<leader>y", group = "Yank/Copy" })

local function truncate(text, max_len)
  max_len = max_len or 50
  local single_line = text:gsub("\n", "\\n")
  if #single_line > max_len then
    return single_line:sub(1, max_len) .. "..."
  end
  return single_line
end

-- Yank to system clipboard
vim.keymap.set("v", "<leader>yy", function()
  vim.cmd('normal! "+y')
  print("Yanked: " .. truncate(vim.fn.getreg("+")))
end, { desc = "Yank to system clipboard" })

vim.keymap.set("n", "<leader>yy", function()
  vim.cmd('normal! "+yy')
  print("Yanked: " .. truncate(vim.fn.getreg("+")))
end, { desc = "Yank line to system clipboard" })

-- Copy git remote permalink to system clipboard
local gitlinker = require("gitlinker")
vim.keymap.set("n", "<leader>yg", function()
  gitlinker.get_buf_range_url("n")
end, { desc = "Copy git permalink" })
vim.keymap.set("v", "<leader>yg", function()
  gitlinker.get_buf_range_url("v")
end, { desc = "Copy git permalink (selection)" })

-- Copy file path to clipboard
vim.keymap.set("n", "<leader>yf", function()
  local filepath = vim.fn.expand("%")
  vim.fn.setreg("+", filepath)
  print("Copied: " .. filepath)
end, { desc = "Copy file path" })

-- Copy file:line to clipboard
vim.keymap.set("n", "<leader>yl", function()
  local file_line = vim.fn.expand("%") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", file_line)
  print("Copied: " .. file_line)
end, { desc = "Copy file:line" })

vim.keymap.set("v", "<leader>yl", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local file_range = vim.fn.expand("%") .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", file_range)
  print("Copied: " .. file_range)
end, { desc = "Copy file:line-range" })

-- System clipboard paste
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from system clipboard" })

-- Delete without yanking (black-hole register)
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "<leader>dd", '"_dd', { desc = "Delete line without yanking" })

-- Change without yanking (black-hole register)
vim.keymap.set({ "n", "v" }, "<leader>c", '"_c', { desc = "Change without yanking" })
vim.keymap.set("n", "<leader>cc", '"_cc', { desc = "Change line without yanking" })

-- Safe visual paste (preserves yank register)
vim.keymap.set("v", "<leader>vp", '"_dP', { desc = "Paste without overwriting register" })

-- Tree sitter keymaps --
-- Tree sitter keymaps are in the plugin configuration for treesitter.
