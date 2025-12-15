-- Language server keymaps --
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Jump to definition" })
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format code" })

-- Diagnostics keymaps --
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
vim.keymap.set("n", "<leader>g", "<cmd>Neogit<CR>", { desc = "Git" })

-- Oil keymaps (file tree editor) --
local function oil_open_float()
  require("oil").open_float(nil, { preview = { vertical = true } }, function()
    print("Opened Oil. Use g? to see available keymaps.")
  end)
end

vim.keymap.set("n", "<leader>o", oil_open_float, { desc = "Open Oil (file tree editor)" })

-- Telescope keymaps --
local frecency = require("telescope").extensions.frecency
local telescope = require("telescope.builtin")

local function telescope_keymap(km, fn, desc)
  vim.keymap.set("n", "<leader>" .. km, fn, { desc = desc })
end

telescope_keymap("ff", function() frecency.frecency { workspace = "CWD" } end, "Find files")
telescope_keymap("fs", telescope.live_grep, "Find text in files")
telescope_keymap("fr", telescope.lsp_references, "Find references of symbol")
telescope_keymap("fg", telescope.git_status, "Find changed files in git")
telescope_keymap("ft", telescope.treesitter, "Find treesitter symbols")

-- Tree sitter keymaps --
-- Tree sitter keymaps are in the plugin configuration for treesitter.
