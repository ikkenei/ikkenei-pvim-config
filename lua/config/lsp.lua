local map = vim.keymap.set

-- === LSP Diagnostics ===
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = {
    on_jump = function()
      vim.diagnostic.open_float(nil, { focus = false })
    end,
  },
})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map("n", "<leader>e", function()
  vim.diagnostic.open_float(nil, {
    scope = "cursor",
    focusable = true,
    close_events = { "CursorMoved", "InsertEnter", "BufLeave" },
    border = "rounded",
    source = "always",
  })
end, { desc = "Show Diagnostic [E]rror float" })

-- === LspAttach ===
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      map("grr", builtin.lsp_references, "[G]oto [R]eferences")
      map("gri", builtin.lsp_implementations, "[G]oto [I]mplementation")
      map("grd", builtin.lsp_definitions, "[G]oto [D]efinition")
      map("gO", builtin.lsp_document_symbols, "Open Document Symbols")
      map("gW", builtin.lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
      map("grt", builtin.lsp_type_definitions, "[G]oto [T]ype Definition")
      map("gh", "<cmd>LspClangdSwitchSourceHeader<CR>", "[G]oto [H]eader")
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/documentHighlight", event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client and client:supports_method("textDocument/inlayHint", event.buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- === LSP серверы ===
local servers = {
  clangd = { capabilities = capabilities, init_options = { fallbackFlags = { "-std=c++17" } } },
  pyright = { capabilities = capabilities },
  bashls = { capabilities = capabilities },
  rust_analyzer = { capabilities = capabilities },
  lua_ls = {
    capabilities = capabilities,
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
            path ~= vim.fn.stdpath("config")
            and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end
      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
            "${3rd}/luv/library",
            "${3rd}/busted/library",
          }),
        },
      })
    end,
    settings = { Lua = {} },
  },
}

require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      require("lspconfig")[server_name].setup(server)
    end,
  },
})

-- Включаем LSP серверы
for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
