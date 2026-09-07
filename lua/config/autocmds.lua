local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
        desc = "Highlight when yanking text",
        group = augroup("highlight-yank", { clear = true }),
        callback = function()
                vim.hl.on_yank()
        end,
})
