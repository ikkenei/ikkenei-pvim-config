local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	{ src = gh("nvim-lua/plenary.nvim") },

	{
		src = gh("catppuccin/nvim"),
		name = "catppuccin",
	},

	{ src = gh("rcarriga/nvim-notify") },

	{ src = gh("nvim-tree/nvim-tree.lua") },
	{ src = gh("nvim-tree/nvim-web-devicons") },

	{ src = gh("nvim-telescope/telescope.nvim") },
	{ src = gh("nvim-telescope/telescope-fzf-native.nvim") },
	{ src = gh("nvim-telescope/telescope-ui-select.nvim") },
	{ src = gh("nvim-telescope/telescope-symbols.nvim") },

	{ src = gh("mason-org/mason.nvim") },
	{ src = gh("mason-org/mason-lspconfig.nvim") },
	{ src = gh("j-hui/fidget.nvim") },
	{ src = gh("neovim/nvim-lspconfig") },

	{ src = gh("saghen/blink.lib") },
	{ src = gh("saghen/blink.cmp") },
	{ src = gh("L3MON4D3/LuaSnip") },

	{ src = gh("stevearc/conform.nvim") },

	{ src = gh("lewis6991/gitsigns.nvim") },
	{ src = gh("folke/which-key.nvim") },
	{ src = gh("folke/todo-comments.nvim") },
	{ src = gh("MeanderingProgrammer/render-markdown.nvim") },
	{ src = gh("NMAC427/guess-indent.nvim") },

	{ src = gh("nvim-treesitter/nvim-treesitter") },

	{ src = gh("stevearc/aerial.nvim") },

	{ src = gh("nvim-mini/mini.nvim") },

	{ src = gh("inkarkat/vim-ingo-library") },
	{ src = gh("inkarkat/vim-mark") },

	{ src = gh("3rd/image.nvim") },
	{ src = gh("benlubas/molten-nvim") },

	{ src = gh("obsidian-nvim/obsidian.nvim") },
})

local map = vim.keymap.set

require("catppuccin").setup({
	transparent_background = true,
	auto_integrations = true,
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		notify = false,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
		-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
	},
})

-- === nvim-tree ===
require("nvim-tree").setup()
map("n", "<leader>o", "<cmd>NvimTreeToggle<CR>", { desc = "t[O]ggle nvim-tree" })

-- === gitsigns ===
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	signcolumn = true,
	auto_attach = true,
	attach_to_untracked = false,
})

-- === which-key ===
require("which-key").setup({
	delay = 0,
	icons = { mappings = vim.g.have_nerd_font },
	spec = {
		{ "<leader>s", group = "[S]earch",    mode = { "n", "v" } },
		{ "<leader>t", group = "[T]oggle" },
		{ "<leader>h", group = "Git [H]unk",  mode = { "n", "v" } },
		{ "gr",        group = "LSP Actions", mode = { "n" } },
	},
})

-- === telescope ===
local telescope_module = require("telescope")
telescope_module.setup({
	extensions = {
		["ui-select"] = { require("telescope.themes").get_dropdown() },
	},
})
pcall(telescope_module.load_extension, "fzf")
pcall(telescope_module.load_extension, "ui-select")

local builtin = require("telescope.builtin")
local opts = { noremap = true, silent = true }

map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
map("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
map({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
map("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
map("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
map("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })
map("n", "<leader>s/", function()
	builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
end, { desc = "[S]earch [/] in Open Files" })
map("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- === conform.nvim ===
local conform_module = require("conform")
conform_module.setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local enable_filetypes = { lua = true }
		if enable_filetypes[vim.bo[bufnr].filetype] then
			return { timeout_ms = 500, lsp_format = "fallback" }
		else
			return nil
		end
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "iasort", "black" },
		rust = { "rustfmt" },
		cpp = { "clang-format" },
		c = { "clang-format" },
	},
})
vim.keymap.set("n", "<leader>f", function()
	conform_module.format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

require("fidget").setup({})

-- === blink.cmp ===
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false, auto_show_delay_ms = 100 } },
	sources = { default = { "lsp", "path", "snippets" } },
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" },
	signature = { enabled = true },
})

-- === LuaSnip ===
local luasnip_module = require("luasnip")
luasnip_module.setup({})

map({ "i" }, "<C-K>", function()
	luasnip_module.expand()
end, { silent = true })
map({ "i", "s" }, "<C-L>", function()
	luasnip_module.jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-J>", function()
	luasnip_module.jump(-1)
end, { silent = true })

map({ "i", "s" }, "<C-E>", function()
	if luasnip_module.choice_active() then
		luasnip_module.change_choice(1)
	end
end, { silent = true })

-- === todo-comments ===
require("todo-comments").setup({})

-- === mini.nvim ===
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup({})
require("mini.statusline").setup({
	use_icons = vim.g.have_nerd_font,
	section_location = function()
		return "%2l:%-2v"
	end,
})

require("guess-indent").setup({
	auto_cmd = true,
})

-- require("notify").setup({
-- 	fps = 60,
-- 	minimum_width = 20,
-- 	background_colour = "#000000",
-- 	render = "default",
-- 	time_formats = {
-- 		notification = "%T",
-- 		notification_history = "%F %T"
-- 	},
-- 	level = 0,
-- })
-- vim.notify = require("notify")

require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
	highlight = { enable = true },
	indent = { enable = true },
	auto_install = false,
})
local parsers = {
	"bash",
	"c",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"vim",
	"rust",
	"python",
	"meson",
	"cmake",
	"dockerfile",
	"gitignore",
	"glsl",
	"mermaid",
	"objdump",
}
require("nvim-treesitter").install(parsers)

require("aerial").setup({
	-- optionally use on_attach to set keymaps when aerial has attached to a buffer
	on_attach = function(bufnr)
		-- Jump forwards/backwards with '{' and '}'
		map("n", "[s", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Next symbol" })
		map("n", "]s", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Prev symbol" })
	end,
})
map("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle [A]erial outline" } )

map("n", "<localleader>m", "<Plug>MarkSet", { desc = "Mark word (whole word)" })
map("n", "<localleader>gm", "<Plug>MarkPartialWord", { desc = "Mark word (partial)" })
map("x", "<localleader>m", "<Plug>MarkSet", { desc = "Mark selection" })
map("n", "<localleader>r", "<Plug>MarkRegex", { desc = "Mark regex" })
map("n", "<localleader>n", "<Plug>MarkClear", { desc = "Clear mark under cursor" })
map("n", "<localleader>N", "<Plug>MarkAllClear", { desc = "Clear ALL marks" })
map("n", "<localleader>*", "<Plug>MarkSearchCurrentNext", { desc = "Next occurrence of current mark" })
map("n", "<localleader>#", "<Plug>MarkSearchCurrentPrev", { desc = "Previous occurrence of current mark" })
map("n", "<localleader>/", "<Plug>MarkSearchAnyNext", { desc = "Next occurrence of ANY mark" })
map("n", "<localleader>?", "<Plug>MarkSearchAnyPrev", { desc = "Previous occurrence of ANY mark" })

require("image").setup({
	backend = "kitty",
	kitty_method = "normal",
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = false,
			download_remote_images = true,
			only_render_image_at_cursor = false,
			only_render_image_at_cursor_mode = "popup", -- or "inline"
			floating_windows = false,                -- if true, images will be rendered in floating markdown windows
			filetypes = { "markdown", "vimwiki" },   -- markdown extensions (ie. quarto) can go here
		},
	},
	render = {
		min_width = 40,
		max_width = 80,
	},
})
