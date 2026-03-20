return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    -- See all settings:
    -- https://github.com/akinsho/toggleterm.nvim
    require("toggleterm").setup({
      shell = vim.fn.exepath("zsh")
    })
  end
}
