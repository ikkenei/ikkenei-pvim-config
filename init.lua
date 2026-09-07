vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true
vim.g.loaded_ruby_provider = 0

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.plugins")
require("config.lsp")

vim.cmd.colorscheme("catppuccin-nvim")
