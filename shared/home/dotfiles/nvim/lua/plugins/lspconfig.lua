return {
  "neovim/nvim-lspconfig",
  config = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {
              'vim',
              'require'
            },
          },
          workspace = {
            library = vim.list_extend(
            -- Make the server aware of Neovim runtime files
              vim.api.nvim_get_runtime_file("", true),
              -- Lazy plugins are installed into the standard nvim data path
              -- under the `/lazy` directory. LuaLS should be made aware of them
              -- too.
              { vim.fn.stdpath("data") .. "/lazy" }
            ),
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        }
      }
    })

    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          inlayHints = {
            bindingModeHints = { enable = true },
            chainingHints = { enable = true },
            closureReturnTypeHints = { enable = "always" },
            lifetimeElisionHints = { enable = "always" },
            typeHints = { enable = true },
            parameterHints = { enable = true },
          },
          workspace = {
            symbol = {
              search = {
                kind = "all_symbols"
              }
            }
          }
        }
      }
    })

    vim.lsp.config("qmlls", {
      cmd = { "qmlls", "-E" }
    })

    vim.lsp.enable({
      "clangd",
      "cssls",
      "eslint",
      "golangci_lint_ls",
      "gopls",
      "html",
      "jsonls",
      "lua_ls",
      "nil_ls",
      "qmlls",
      "rust_analyzer",
      "ts_ls",
    })
  end
}
