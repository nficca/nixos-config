return function(map)
  -- Toggles diagnostics between:
  --   - separate lines (virtual_lines)
  --   - inline text (virtual_text)
  --   - none
  local toggle_diagnostics = function()
    local cfg = vim.diagnostic.config()
    if not cfg then return end

    -- Cycle: none -> text -> lines -> none
    vim.diagnostic.config({
      virtual_text = not cfg.virtual_lines and not cfg.virtual_text,
      virtual_lines = not not cfg.virtual_text,
    })
  end

  map("n", "<leader>di", toggle_diagnostics, "Toggle inline diagnostics")
  map("n", "<leader>do", vim.diagnostic.open_float, "Open in float")
  map("n", "<leader>dt", "<cmd>Trouble diagnostics toggle<cr>", "Toggle Trouble")
end
