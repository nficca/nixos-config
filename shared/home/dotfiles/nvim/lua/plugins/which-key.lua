return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function ()
    local wk = require("which-key")
    wk.add({ "<leader>f", group = "Find things" })
    wk.add({ "<leader>x", group = "Diagnostics" })
    wk.add({ "<leader>t", group = "File tree" })
    wk.add({ "<leader>l", group = "Language server" })
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Show local keymaps",
    },
  },
}
