-- Suppress nvim-treesitter-textobjects' default mappings; we bind our own below.
-- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects#available-textobjects
vim.g.no_plugin_maps = true

-- ---------------------------------------------------------------------------
-- Highlighting / indent / folds
-- ---------------------------------------------------------------------------
-- nvim-treesitter (main branch) does not enable highlighting on its own; the
-- user is expected to call vim.treesitter.start() per buffer.
-- See: https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then return end
    -- pcall so that filetypes whose parser isn't in the Nix grammar set
    -- silently fall back to vim's regex syntax instead of erroring.
    local ok = pcall(vim.treesitter.start, bufnr, lang)
    if not ok then return end
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldmethod = "expr"
  end,
})

-- ---------------------------------------------------------------------------
-- nvim-treesitter-textobjects
-- ---------------------------------------------------------------------------
require("nvim-treesitter-textobjects").setup({
  select = {
    -- Jump forward to the next textobject if the cursor isn't already inside one.
    lookahead = true,
  },
  move = {
    -- Push the cursor's pre-jump position onto the jumplist so <C-o> returns.
    set_jumps = true,
  },
})

local select = function(query)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
  end
end

local move = function(fn, query, group)
  return function()
    require("nvim-treesitter-textobjects.move")[fn](query, group or "textobjects")
  end
end

-- See https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
-- for the full set of available @captures.
local sel_map = {
  ["a="] = "@assignment.outer",
  ["i="] = "@assignment.inner",
  ["l="] = "@assignment.lhs",
  ["r="] = "@assignment.rhs",
  ["aa"] = "@parameter.outer",
  ["ia"] = "@parameter.inner",
  ["ai"] = "@conditional.outer",
  ["ii"] = "@conditional.inner",
  ["al"] = "@loop.outer",
  ["il"] = "@loop.inner",
  ["af"] = "@call.outer",
  ["if"] = "@call.inner",
  ["am"] = "@function.outer",
  ["im"] = "@function.inner",
  ["ac"] = "@class.outer",
  ["ic"] = "@class.inner",
}
for lhs, query in pairs(sel_map) do
  vim.keymap.set({ "x", "o" }, lhs, select(query), { desc = "select " .. query })
end

local move_groups = {
  goto_next_start = {
    ["]f"] = { "@call.outer" },
    ["]m"] = { "@function.outer" },
    ["]c"] = { "@class.outer" },
    ["]i"] = { "@conditional.outer" },
    ["]l"] = { "@loop.outer" },
    -- @scope and @fold live in non-default query groups; pass the group name explicitly.
    ["]s"] = { "@scope", "locals" },
    ["]z"] = { "@fold", "folds" },
  },
  goto_next_end = {
    ["]F"] = { "@call.outer" },
    ["]M"] = { "@function.outer" },
    ["]C"] = { "@class.outer" },
    ["]I"] = { "@conditional.outer" },
    ["]L"] = { "@loop.outer" },
  },
  goto_previous_start = {
    ["[f"] = { "@call.outer" },
    ["[m"] = { "@function.outer" },
    ["[c"] = { "@class.outer" },
    ["[i"] = { "@conditional.outer" },
    ["[l"] = { "@loop.outer" },
  },
  goto_previous_end = {
    ["[F"] = { "@call.outer" },
    ["[M"] = { "@function.outer" },
    ["[C"] = { "@class.outer" },
    ["[I"] = { "@conditional.outer" },
    ["[L"] = { "@loop.outer" },
  },
}
for fn, maps in pairs(move_groups) do
  for lhs, args in pairs(maps) do
    vim.keymap.set({ "n", "x", "o" }, lhs, move(fn, args[1], args[2]), { desc = fn .. " " .. args[1] })
  end
end

-- ---------------------------------------------------------------------------
-- Incremental selection
-- ---------------------------------------------------------------------------
-- <C-space> in normal mode starts a selection at the current treesitter node;
-- pressing it again in visual mode walks up to the parent node. <BS> walks
-- back down. We track the chain in sel_stack so that shrinking is exact (just
-- popping a node) rather than reconstructing it from the cursor position.
local sel_stack = {}

local function select_node(node)
  if not node then return end
  local sr, sc, er, ec = node:range()
  -- `normal! v` toggles visual mode, so if we're already in visual mode (from
  -- a previous grow), drop out first. Otherwise the next `normal! v` would
  -- exit visual mode instead of refreshing the selection.
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! \27") -- <Esc>
  end
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
end

vim.keymap.set("n", "<C-space>", function()
  local node = vim.treesitter.get_node()
  if not node then return end
  sel_stack = { node }
  select_node(node)
end, { desc = "TS init selection" })

vim.keymap.set("x", "<C-space>", function()
  local current = sel_stack[#sel_stack]
  local parent = current and current:parent()
  if not parent then return end
  table.insert(sel_stack, parent)
  select_node(parent)
end, { desc = "TS grow selection" })

vim.keymap.set("x", "<BS>", function()
  if #sel_stack <= 1 then return end
  table.remove(sel_stack)
  select_node(sel_stack[#sel_stack])
end, { desc = "TS shrink selection" })
