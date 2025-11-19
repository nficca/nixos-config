local toggle_diagnostics = function()
  local cfg = vim.diagnostic.config()

  if not cfg then
    print("Could not find diagnostic config")
    return
  end

  local enable_lines = false
  local enable_text = false

  if not (cfg.virtual_lines or cfg.virtual_text) then
    enable_lines = true
    enable_text = false
  elseif cfg.virtual_lines then
    enable_lines = false
    enable_text = true
  end

  vim.diagnostic.config({ virtual_lines = enable_lines })
  vim.diagnostic.config({ virtual_text = enable_text })
end

-- Language server keymaps --
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Jump to definition" })
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format code" })

-- Diagnostics keymaps --
vim.keymap.set("n", "<leader>xt", toggle_diagnostics, { desc = "Toggle inline diagnostics" })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble" })

-- Git keymaps --
vim.keymap.set("n", "<leader>g", "<cmd>Neogit<CR>", { desc = "Git" })

-- File tree keymaps --
vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFile<CR>", { desc = "Open current buffer in file tree" })
vim.keymap.set("n", "<leader>tr", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file tree" })

-- Telescope keymaps --
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope frecency workspace=CWD<CR>",  { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find text in files" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope lsp_references<CR>", { desc = "Find references of current word under cursor" })

-- Tree sitter keymaps --
-- Tree sitter keymaps are in the plugin configuration for treesitter.
