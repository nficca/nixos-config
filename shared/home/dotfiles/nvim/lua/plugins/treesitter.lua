return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "rust", "html", "css", "javascript", "json", "lua", "typescript" },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      highlight = {
        enable = true
      },
      indent = {
        enable = true
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>"
        }
      },
      modules = {},
    })
  end
}
