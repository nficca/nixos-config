-- Keymaps are organized into submodules by group (e.g. find.lua, lsp.lua).
-- Each submodule receives a shared `map` helper and defines its own bindings.
--
-- This file is the central index: all top-level <leader> allocations are
-- visible here, so conflicts are easy to spot. Group labels and submodule
-- requires are kept here rather than scattered across plugin specs because
-- some groups (like diagnostics) span multiple plugins.
--
-- Plugin-internal keymaps (treesitter text objects, cmp completion) stay in
-- their plugin configs — those are plugin setup, not user keybindings.

local which_key = require("which-key")

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Which-key group labels (centralized namespace overview)
which_key.add({ "<leader>l", group = "Language server tools" })
which_key.add({ "<leader>d", group = "Diagnostics" })
which_key.add({ "<leader>f", group = "Find things" })
which_key.add({ "<leader>y", group = "System clipboard copy options" })
which_key.add({ "<leader>g", group = "Git" })

-- WhichKey shows you available keybindings as a popup
map("n", "<leader>?", function()
  which_key.show({ global = false })
end, "Show local keymaps")

-- Submodules
require("config.keymaps.lsp")(map)
require("config.keymaps.diagnostics")(map)
require("config.keymaps.find")(map)
require("config.keymaps.clipboard")(map)
require("config.keymaps.hoversplit")(map)
require("config.keymaps.git")(map)
require("config.keymaps.oil")(map)
require("config.keymaps.terminal")(map)
