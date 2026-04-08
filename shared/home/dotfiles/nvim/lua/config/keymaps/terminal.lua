return function(map)
  map("n", "<leader>t", "<cmd>ToggleTerm direction=float<CR>", "Open terminal")
  map("n", "<leader>T", function()
    local term = require("toggleterm.terminal").get_or_create_term()
    local directory = vim.fn.expand("%:p:h")

    if not term:is_open() then
      term:open(nil, "float")
    end

    term:change_dir(directory)

    if not term:is_focused() then
      term:focus()
    end
  end, "Open terminal in current directory")
end
