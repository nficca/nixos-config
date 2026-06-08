return {
  "nvim-lualine/lualine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = "ayu_dark",
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
    },
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
          padding = { left = 0, right = 0 }
        },
        {
          "filename",
          path = 1,
          file_status = true,
          padding = { left = 0, right = 0 },
          symbols = {
            modified = '', -- Text to show when the file is modified.
            readonly = '', -- Text to show when the file is non-modifiable or readonly.
            unnamed = '', -- Text to show for unnamed buffers.
            newfile = '', -- Text to show for newly created file bef
          }
        },
      },
      lualine_c = {},
      lualine_x = { "location" },
      lualine_y = { "diagnostics" },
      lualine_z = { "lsp_status" }
    }
  }
}
