return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-frecency.nvim" },
  config = function()
    local telescope = require("telescope")

    telescope.load_extension("frecency")
    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending"
      },
    })
  end,
  keys = {
    { "<leader>ff", "<cmd>Telescope frecency workspace=CWD<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Find text in files" }
  }
}
