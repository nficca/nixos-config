return function(map)
  local function oil_open_float()
    require("oil").open_float(nil, { preview = { vertical = true } }, function()
      print("Opened Oil. Use g? to see available keymaps.")
    end)
  end

  map("n", "<leader>o", oil_open_float, "Open Oil (file tree editor)")
end
