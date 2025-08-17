return {
  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    config = function()
      require('github-theme').setup({
        options = {
          transparent = true
        }
      })
    end
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("lualine").setup()
    end
  },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
      require("which-key").add({
        { "<leader>t", group = "File Tree" }
      })
    end,
    keys = {
      { "<leader>tt", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
      { "<leader>tf", "<cmd>NvimTreeFindFile<CR>", desc = "Open file tree to current buffer" }
    }
  },

  {
    "dmtrKovalenko/fff.nvim",
    build = "nix run .#release",
    opts = {
      width = 0.9,
      prompt = '> '
    },
    keys = {
      {
        "<leader>f",
        function()
          require("fff").find_files() -- or find_in_git_root() if you only want git files
        end,
        desc = "Open file picker",
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  { "tpope/vim-sleuth" },

  { "lewis6991/gitsigns.nvim" },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
    },
    keys = {
      { "<leader>g", "<cmd>Neogit<CR>", desc = "Open Neogit" }
    }
  },

  { "voldikss/vim-floaterm" }
}
