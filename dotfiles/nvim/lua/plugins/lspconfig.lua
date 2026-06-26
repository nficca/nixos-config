return {
  "neovim/nvim-lspconfig",
  dependencies = { "b0o/schemastore.nvim" },
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

    -- ron-lsp ships no built-in nvim-lspconfig entry, so define it in full.
    -- See: https://github.com/jasonjmcghee/ron-lsp
    vim.lsp.config("ron_lsp", {
      cmd = { "ron-lsp" },
      filetypes = { "ron" },
      root_markers = { "Cargo.toml", ".git" },
    })

    -- JSON Schema support. The SchemaStore catalog auto-associates common
    -- files (package.json, tsconfig.json, GitHub Actions, etc.) with their
    -- schemas from schemastore.org.
    --
    -- For per-project schemas, add a `$schema` key to the JSON file itself;
    -- jsonls resolves it relative to the file, so a local schema works:
    --   { "$schema": "./schemas/foo.schema.json", ... }
    -- An inline `$schema` overrides the catalog for that file.
    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    vim.lsp.enable({
      "clangd",
      "cmake",
      "cssls",
      "eslint",
      "golangci_lint_ls",
      "gopls",
      "html",
      "jsonls",
      "lua_ls",
      "nil_ls",
      "qmlls",
      "ron_lsp",
      "ruby_lsp",
      "rust_analyzer",
      "ts_ls",
    })
  end
}
