-- line numbers
vim.opt.number = true;
vim.opt.relativenumber = true;

-- whitespace
vim.opt.list = true;
vim.opt.listchars = { tab = '→ ', leadmultispace = '·', trail = '·' };

-- tabs
vim.opt.expandtab = true;
vim.opt.tabstop = 4;
vim.opt.shiftwidth = 4;

-- colorscheme
vim.cmd.colorscheme('github_dark_default');
vim.opt.termguicolors = true;
vim.opt.winblend = 10;
vim.opt.pumblend = 10;
