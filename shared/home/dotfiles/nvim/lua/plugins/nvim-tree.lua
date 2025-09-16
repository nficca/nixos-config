return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
  end,
  keys = {
    { "<leader>tt", "<cmd>NvimTreeToggle<CR>",  desc = "Toggle file tree" },
    {
      "<leader>tf",
      "<cmd>NvimTreeFindFile<CR>",
      desc = "Open file tree to current buffer"
    },
    { "<leader>tr", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file tree" }
  }
}
