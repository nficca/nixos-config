return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        layout_strategy = "vertical",
        layout_config = {
          prompt_position = "top",
          mirror = true,
          height = 0.9,
          width = 0.9,
        },
        sorting_strategy = "ascending"
      },
      extensions = {
        fzf = {
          fuzzy = true,                   -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true,    -- override the file sorter
          case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        }
      }
    })

    telescope.load_extension("fzf")
  end
}
