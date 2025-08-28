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
      require("lualine").setup({
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1
            }
          },
          lualine_x = {
            {
              'diagnostics',
              sources = {'nvim_diagnostic'},
              symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}
            }
          }
        }
      })
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
      { "<leader>tf", "<cmd>NvimTreeFindFile<CR>", desc = "Open file tree to current buffer" },
      { "<leader>tr", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file tree" }
    }
  },

  {
    "dmtrKovalenko/fff.nvim",

    -- You can build this via nix or cargo. Uncomment one of the following:
    -- build = "cargo build --release"
    build = "nix run .#release",
    -- You may run into a timeout error when Lazy tries to build this plugin.
    -- I am not sure where exactly that timeout comes from. If it's from Lazy
    -- itself, there does not appear to be an option to increase this timeout.
    -- So if this happens, you can try running the build command directly from
    -- the plugin directory, which should be ~/.local/share/nvim/lazy/fff.nvim.
    
    opts = {
      prompt = '> ',
      layout = {
        width = 0.9,
        height = 0.8,
        prompt_position = 'top'
      }
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

  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('lspconfig').rust_analyzer.setup({ capabilities = capabilities })
      require('lspconfig').nil_ls.setup({ capabilities = capabilities })
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
    end
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = {
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Esc>'] = cmp.mapping.abort(),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        })
      })
    end
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup {}
      require("which-key").add({
        { "<leader>x", group = "Trouble" }
      })
    end,
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  { "sphamba/smear-cursor.nvim", opts = {} },

  { "mg979/vim-visual-multi" }
}
