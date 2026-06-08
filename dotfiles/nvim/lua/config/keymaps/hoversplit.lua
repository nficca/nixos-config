return function(map)
  local hoversplit = require("hoversplit")
  map("n", "<leader>h", hoversplit.split_remain_focused, "Toggle hoversplit")
end
