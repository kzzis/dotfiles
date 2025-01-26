return { -- lazy.nvim をプラグイン管理に使用
{'folke/lazy.nvim'}, -- nvim-web-devicons: アイコンサポート
{
    'nvim-tree/nvim-web-devicons',
    config = function()
        require('nvim-web-devicons').setup {
            default = true
        }
    end
}, -- lualine.nvim: ステータスライン
{
    'nvim-lualine/lualine.nvim',
    dependencies = {'nvim-tree/nvim-web-devicons'}, -- アイコンを表示するために必要
    config = function()
        require('lualine').setup {
            options = {
                theme = 'catppuccin', -- カラースキームをCatppuccinに変更
                icons_enabled = true,
                section_separators = {
                    left = '',
                    right = ''
                },
                component_separators = {
                    left = '',
                    right = ''
                }
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            extensions = {'nvim-tree', 'quickfix'}
        }
    end
}, -- nvim-tree: ファイルツリー
{
    'nvim-tree/nvim-tree.lua',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
        require("nvim-tree").setup({
            view = {
                adaptive_size = true
            },
            git = {
                enable = false
            },
            actions = {
                open_file = {
                    resize_window = true
                }
            }
        })
    end
}, -- Catppuccin テーマ
{
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha" -- テーマのスタイル (mocha, latte, frappe, macchiato)
        })
        vim.cmd.colorscheme("catppuccin")
    end
}, -- Telescope: ファジーファインダー
{
    'nvim-telescope/telescope.nvim',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
        local actions = require('telescope.actions')

        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-c>"] = actions.close
                    },
                    n = {
                        ["q"] = actions.close,
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous
                    }
                }
            }
        })
    end
}, -- mason.nvim: LSP サーバーのインストールと管理
{
    'williamboman/mason.nvim',
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {"ts_ls", "pyright", "rust_analyzer", "intelephense"} -- 必要な LSP サーバーにintelephenseを追加
        })
    end
}, -- nvim-lspconfig: Neovim のビルトイン LSP クライアントを設定
{
    'neovim/nvim-lspconfig',
    dependencies = {'williamboman/mason-lspconfig.nvim'},
    config = function()
        local lspconfig = require('lspconfig')

        local on_attach = function(client, bufnr)
            local opts = {
                noremap = true,
                silent = true,
                buffer = bufnr
            }
            local map = vim.keymap.set

            -- LSP用キーマッピング
            map("n", "gd", vim.lsp.buf.definition, opts)
            map("n", "gD", vim.lsp.buf.declaration, opts)
            map("n", "gi", vim.lsp.buf.implementation, opts)
            map("n", "gr", vim.lsp.buf.references, opts)
            map("n", "K", vim.lsp.buf.hover, opts)
            map("n", "<leader>rn", vim.lsp.buf.rename, opts)
            map("n", "[d", vim.diagnostic.goto_prev, opts)
            map("n", "]d", vim.diagnostic.goto_next, opts)
            map("n", "<leader>f", function()
                vim.lsp.buf.format({
                    async = true
                })
            end, opts)

            -- 保存時に自動フォーマット
            if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({
                            async = false
                        })
                    end
                })
            end
        end

        -- intelephenseのLSP設定
        lspconfig.intelephense.setup({
            on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = true
                on_attach(client, bufnr)
            end,
            filetypes = {"php"},
            root_dir = lspconfig.util.root_pattern("composer.json", ".git"),
            settings = {
                intelephense = {
                    format = {
                        enable = true -- フォーマットを有効化
                    }
                }
            }
        })
    end
}, {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = {
        workspaces = {{
            name = "private", -- プライベートVault
            path = "~/Documents/PrivateVault"
        }, {
            name = "work", -- 仕事用Vault
            path = "~/Documents/ObsidianVault",
            overrides = {}
        }},
        daily_notes = {
            folder = "02_Daily", -- デイリーノートを保存するフォルダ
            date_format = "%Y-%m-%d", -- デイリーノートの日付形式
            template = "04_Templates/Vim_Daily.md" -- テンプレートファイルのパス
        },
        templates = {
            folder = "03_Templates", -- テンプレートフォルダ
            date_format = "%Y-%m-%d",
            time_format = "%H:%M"
        }
    },
    config = function(_, opts)
        -- Obsidianの設定を読み込み
        require("obsidian").setup(opts)

        -- キーバインド設定
        local map = vim.keymap.set

        -- Private Vaultを開く
        map("n", "<C-p>", function()
            require("obsidian").util.open_vault("private")
        end, {
            desc = "Open private vault"
        })

        -- Work Vaultを開く
        map("n", "<C-w>", function()
            require("obsidian").util.open_vault("work")
        end, {
            desc = "Open work vault"
        })
    end
}, {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
        local null_ls = require('null-ls')

        null_ls.setup({
            sources = {null_ls.builtins.formatting.prettier -- Prettierをフォーマット用に設定
            },
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({
                                async = false,
                                bufnr = bufnr
                            })
                        end
                    })
                end
            end
        })
    end
}, {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true -- Treesitterを使って括弧の補完を高度化
        })
    end
}, -- nvim-cmp補完プラグイン
{
    "hrsh7th/nvim-cmp", -- メインの補完エンジン
    dependencies = {"hrsh7th/cmp-nvim-lsp", -- LSPソース
    "hrsh7th/cmp-buffer", -- バッファ内の補完
    "hrsh7th/cmp-path", -- ファイルパス補完
    "hrsh7th/cmp-cmdline", -- コマンドライン補完
    "L3MON4D3/LuaSnip", -- スニペットエンジン
    "saadparwaiz1/cmp_luasnip" -- スニペット補完
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({
                    select = true
                }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, {"i", "s"}),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, {"i", "s"})
            }),
            sources = cmp.config.sources({{
                name = "nvim_lsp"
            }, {
                name = "luasnip"
            }, {
                name = "buffer"
            }, {
                name = "path"
            }})
        })

        -- コマンドライン補完
        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {{
                name = "buffer"
            }}
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({{
                name = "path"
            }}, {{
                name = "cmdline"
            }})
        })
    end
}, {
    "mattn/emmet-vim",
    lazy = false -- 常に読み込む
}}

