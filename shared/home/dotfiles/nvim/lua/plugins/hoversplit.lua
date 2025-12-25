return {
  "nficca/hoversplit.nvim",
  config = function()
    require("hoversplit").setup({
      -- Configure keybindings in the keymaps.lua file instead
      key_bindings_disabled = true
    })
  end
}
