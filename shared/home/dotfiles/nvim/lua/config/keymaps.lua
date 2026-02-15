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
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format code" })
vim.keymap.set("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

which_key.add({ "<leader>lx", group = "Diagnostics"})

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
which_key.add({ "<leader>ls", group = "Toggle LSP splits"})
vim.keymap.set("n", "<leader>lsv", hoversplit.vsplit_remain_focused, { desc = "Toggle LSP split (vertical)" })
vim.keymap.set("n", "<leader>lsh", hoversplit.split_remain_focused, { desc = "Toggle LSP split (horizontal)" })


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
telescope_keymap("fs", telescope.lsp_dynamic_workspace_symbols, "Find symbols")
telescope_keymap("fj", telescope.jumplist, "Find jumplist entries")

telescope_keymap("F", telescope.resume, "Resume previous search")

-- Clipboard and Register keymaps --

-- Yank keymaps --
which_key.add({ "<leader>y", group = "Yank/Copy" })

-- System clipboard yank (copy)
vim.keymap.set("v", "<leader>yy", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Yank line to system clipboard" })

-- Gitlinker (copy git permalink)
local gitlinker = require("gitlinker")
vim.keymap.set("n", "<leader>yg", function()
  gitlinker.get_buf_range_url("n")
end, { desc = "Copy git permalink" })
vim.keymap.set("v", "<leader>yg", function()
  gitlinker.get_buf_range_url("v")
end, { desc = "Copy git permalink (selection)" })

-- System clipboard paste
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({"n", "v"}, "<leader>P", '"+P', { desc = "Paste before from system clipboard" })

-- Delete without yanking (black-hole register)
vim.keymap.set({"n", "v"}, "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "<leader>dd", '"_dd', { desc = "Delete line without yanking" })

-- Change without yanking (black-hole register)
vim.keymap.set({"n", "v"}, "<leader>c", '"_c', { desc = "Change without yanking" })
vim.keymap.set("n", "<leader>cc", '"_cc', { desc = "Change line without yanking" })

-- Safe visual paste (preserves yank register)
vim.keymap.set("v", "<leader>vp", '"_dP', { desc = "Paste without overwriting register" })

-- Cut to system clipboard (delete + yank)
vim.keymap.set({"n", "v"}, "<leader>x", '"+d', { desc = "Cut to system clipboard" })
vim.keymap.set("n", "<leader>xx", '"+dd', { desc = "Cut line to system clipboard" })

-- Tree sitter keymaps --
-- Tree sitter keymaps are in the plugin configuration for treesitter.
