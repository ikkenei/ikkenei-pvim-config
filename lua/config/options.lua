local opt = vim.opt
local o = vim.o

o.number = true
o.mouse = ""
o.showmode = false
o.clipboard = ""
o.breakindent = true
o.undofile = true
o.confirm = true

o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

o.signcolumn = "yes"
o.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.inccommand = "split"
o.cursorline = true
o.scrolloff = 4

o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.autoindent = true
o.smartindent = true

o.splitright = true
o.splitbelow = true

o.updatetime = 250
o.timeoutlen = 300

o.termguicolors = true

o.backup = false
o.swapfile = false
