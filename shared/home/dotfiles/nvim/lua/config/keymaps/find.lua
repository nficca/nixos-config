return function(map)
  local telescope = require("telescope.builtin")

  map("n", "<leader>ff", function()
    telescope.find_files({
      find_command = { "rg", "--files", "--sortr=modified" }
    })
  end, "Find files (sort by modified)")
  map("n", "<leader>ft", telescope.live_grep, "Find text (regex)")
  map("n", "<leader>fT", function()
    telescope.live_grep({
      additional_args = function(_opts)
        return { "--fixed-strings" }
      end,
    })
  end, "Find text (literal)")
  map("n", "<leader>fb", function() telescope.buffers({ sort_lastused = true }) end, "Find opened buffers")
  map("n", "<leader>fr", telescope.lsp_references, "Find references of symbol")
  map("n", "<leader>fg", telescope.git_status, "Find git changes")
  map("n", "<leader>fs", telescope.lsp_dynamic_workspace_symbols, "Find symbols")
  map("n", "<leader>fj", telescope.jumplist, "Find jumplist entries")

  map("n", "<leader>F", telescope.resume, "Resume previous search")
end
