return function(map)
  local gitsigns = require("gitsigns")

  -- Neogit
  map("n", "<leader>gg", "<cmd>Neogit<CR>", "Neogit")

  -- Navigation (fall back to default ]h/[h in diff mode)
  vim.keymap.set("n", "]h", function()
    if vim.wo.diff then
      vim.cmd.normal({ "]h", bang = true })
    else
      gitsigns.nav_hunk("next")
    end
  end, { desc = "Next hunk" })

  vim.keymap.set("n", "[h", function()
    if vim.wo.diff then
      vim.cmd.normal({ "[h", bang = true })
    else
      gitsigns.nav_hunk("prev")
    end
  end, { desc = "Previous hunk" })

  -- Stage / Reset
  map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
  map("v", "<leader>gs", function()
    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Stage hunk")
  map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
  map("v", "<leader>gr", function()
    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Reset hunk")
  map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
  map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")

  -- Preview
  map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
  map("n", "<leader>gi", gitsigns.preview_hunk_inline, "Preview hunk inline")

  -- Blame
  map("n", "<leader>gb", function()
    gitsigns.blame_line({ full = true })
  end, "Blame line")

  -- Diff
  map("n", "<leader>gd", gitsigns.diffthis, "Diff against index")
  map("n", "<leader>gD", function()
    gitsigns.diffthis("~")
  end, "Diff against previous commit")

  -- Quickfix
  map("n", "<leader>gQ", function()
    gitsigns.setqflist("all")
  end, "Quickfix all repo changes")
  map("n", "<leader>gq", gitsigns.setqflist, "Quickfix buffer changes")
end
