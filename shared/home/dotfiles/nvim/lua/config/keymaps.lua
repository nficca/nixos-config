-- WhichKey shows you available keybindings as a popup
local which_key = require("which-key")
vim.keymap.set("n", "<leader>?", function()
  which_key.show({ global = false })
end, { desc = "Show local keymaps" })

-- Language server keymaps --
which_key.add({ "<leader>l", group = "Language server tools"})

vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Jump to definition" })
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format code" })
vim.keymap.set("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Hoversplit allow for LSP hover text in a split window
-- Since it's LSP related, its keymaps can share the same prefix
local hoversplit = require("hoversplit")
which_key.add({ "<leader>ls", group = "Toggle LSP splits"})
vim.keymap.set("n", "<leader>lsv", hoversplit.vsplit_remain_focused, { desc = "Toggle LSP split (vertical)" })
vim.keymap.set("n", "<leader>lsh", hoversplit.split_remain_focused, { desc = "Toggle LSP split (horizontal)" })

-- Diagnostics keymaps --
which_key.add({ "<leader>x", group = "Diagnostics" })

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

vim.keymap.set("n", "<leader>xt", toggle_diagnostics, { desc = "Toggle inline diagnostics" })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble" })

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
telescope_keymap("fb", function() telescope.buffers({ sort_lastused = true}) end, "Find opened buffers")
telescope_keymap("fr", telescope.lsp_references, "Find references of symbol")
telescope_keymap("fg", telescope.git_status, "Find git changes")
telescope_keymap("fs", telescope.treesitter, "Find symbols")

telescope_keymap("F", telescope.resume, "Resume previous search")

-- Tree sitter keymaps --
-- Tree sitter keymaps are in the plugin configuration for treesitter.
