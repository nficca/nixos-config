return {
  "nvim-lualine/lualine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    -- Sections:
    -- +-------------------------------------------------+
    -- | A | B | C                             X | Y | Z |
    -- +-------------------------------------------------+
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        {
          "filetype",
          colored = true,
          icon_only = true,
          separator = "",
          padding = { left = 1, right = 0 }
        },
        {
          "filename",
          path = 1,
          file_status = false,
          padding = { left = 0, right = 1 }
        },
      },
      lualine_c = { "location" },
      lualine_x = {},
      lualine_y = { "diagnostics" },
      lualine_z = { "lsp_status" }
    }
  }
}
