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
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
        require('lualine').setup {
            options = {
                theme = 'gruvbox',
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
            git = {
                enable = true,
                ignore = false,
                timeout = 400
            },
            view = {
                adaptive_size = true
            },
            renderer = {
                highlight_git = true, -- Gitステータスのハイライト
                indent_markers = {
                    enable = true, -- インデントガイドを有効化
                    icons = {
                        corner = "└ ",
                        edge = "│ ",
                        item = "│ ",
                        none = "  "
                    }
                }
            }
        })
    end
}, -- Catppuccin テーマ
-- {
--     "catppuccin/nvim",
--     name = "catppuccin",
--     priority = 1000,
--     config = function()
--         require("catppuccin").setup({
--             flavour = "mocha"
--         })
--         vim.cmd.colorscheme("catppuccin")
--     end
-- },
-- Gruvbox テーマ
{
    "ellisonleao/gruvbox.nvim",
    lazy = false, -- 即時読み込み
    priority = 1000, -- テーマの適用を優先
    config = function()
        require("gruvbox").setup({
            contrast = "medium", -- コントラストの設定: "soft", "medium", "hard"
            invert_selection = false -- 選択範囲の色を反転しない
        })
        vim.o.background = "dark" -- 背景をダークモードに設定
        vim.cmd("colorscheme gruvbox") -- Gruvbox テーマを適用
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
}, -- mason.nvim: LSPサーバーのインストールと管理
{
    'williamboman/mason.nvim',
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {"ts_ls", "pyright", "rust_analyzer", "intelephense", "gopls"} -- ts_lsを使用
        })
    end
}, -- nvim-lspconfig: NeovimのビルトインLSPクライアントを設定
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

            vim.diagnostic.config({
                virtual_text = true,
                update_in_insert = true,
                severity_sort = true
            })

            -- 保存時の自動フォーマット
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

        vim.diagnostic.config({
            virtual_text = true,
            update_in_insert = true,
            severity_sort = true
        })
        local diagnostic_timer = nil

        local function show_diagnostics()
            if diagnostic_timer then
                vim.fn.timer_stop(diagnostic_timer) -- 既存のタイマーを停止
            end
            diagnostic_timer = vim.fn.timer_start(1000, function() -- 1000msごとに診断を表示
                vim.diagnostic.open_float(nil, {
                    focusable = false
                })
            end, {
                ['repeat'] = -1
            }) -- 無限ループ
        end

        vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave", "TextChanged"}, {
            callback = function()
                show_diagnostics()
            end
        })
        -- ts_ls（旧tsserver）の設定
        lspconfig.ts_ls.setup({
            on_attach = on_attach,
            filetypes = {"typescript", "typescriptreact", "javascript", "javascriptreact"},
            root_dir = lspconfig.util.root_pattern("tsconfig.json", "package.json", ".git")
        })

        -- intelephenseの設定
        lspconfig.intelephense.setup({
            on_attach = on_attach,
            filetypes = {"php"},
            root_dir = lspconfig.util.root_pattern("composer.json", ".git"),
            settings = {
                intelephense = {
                    format = {
                        enable = true
                    }
                }
            }
        })
        lspconfig.gopls.setup({
            on_attach = function(client, bufnr)
                -- 保存時にフォーマットを実行する設定
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
            end,
            settings = {
                gopls = {
                    gofumpt = true, -- より厳密なフォーマットツールを使用
                    staticcheck = true, -- 静的解析を有効化
                    completeUnimported = true, -- 未インポートのパッケージを補完
                    analyses = {
                        unusedparams = true, -- 未使用のパラメータを警告
                        shadow = true -- 変数のシャドウイングを警告
                    }
                }
            }
        })
    end
}, -- null-ls: Prettierをフォーマッターとして設定
{
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
        local null_ls = require('null-ls')
        null_ls.setup({
            sources = {null_ls.builtins.formatting.prettier, null_ls.builtins.formatting.goimports},
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
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
        })
    end
}, -- nvim-cmp補完プラグイン
{
    "hrsh7th/nvim-cmp",
    dependencies = {"hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline",
                    "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "windwp/nvim-autopairs" -- nvim-autopairs を依存関係に追加
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local cmp_autopairs = require("nvim-autopairs.completion.cmp") -- 追加

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
                    behavior = cmp.ConfirmBehavior.Replace, -- 修正: 補完確定時に既存の単語を置き換える
                    select = false -- 修正: 確定時に現在の選択を保持しない
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

        -- nvim-cmp と nvim-autopairs を連携させる設定
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done()) -- 追加
    end
}, {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true, -- Treesitterを使って括弧の補完を高度化
            map_cr = false,
        })
    end
}, {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = 20, -- ターミナルウィンドウのサイズ
            open_mapping = [[<C-\>]], -- ターミナルを開くためのキー
            hide_numbers = true, -- 行番号を非表示
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            persist_size = true,
            direction = "float", -- 浮きウィンドウとして表示
            close_on_exit = true,
            shell = vim.o.shell, -- システムデフォルトのシェルを使用
            float_opts = {
                border = "curved", -- ボーダーのスタイル
                winblend = 3
            }
        })

        -- Terminal クラスのロード
        local Terminal = require("toggleterm.terminal").Terminal

        -- 通常のターミナル
        local normal_term = Terminal:new({
            cmd = nil, -- 通常のシェルを使用
            direction = "float", -- 浮きウィンドウで開く
            float_opts = {
                border = "curved"
            },
            on_open = function(term)
                vim.cmd("startinsert!") -- 挿入モードで開始
                -- "q" で閉じるマッピングを追加
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {
                    noremap = true,
                    silent = true
                })
            end
        })

        -- 通常ターミナルをトグルする関数
        function _normal_term_toggle()
            normal_term:toggle()
        end

        -- lazygit 専用ターミナル
        local lazygit = Terminal:new({
            cmd = "lazygit", -- 実行コマンド
            direction = "float",
            float_opts = {
                border = "double"
            },
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {
                    noremap = true,
                    silent = true
                })
            end
        })

        -- lazygit をトグルする関数
        function _lazygit_toggle()
            lazygit:toggle()
        end

        -- キーマッピング
        vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua _normal_term_toggle()<CR>", {
            noremap = true,
            silent = true
        }) -- 通常ターミナル
        vim.api.nvim_set_keymap("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>", {
            noremap = true,
            silent = true
        }) -- lazygit
    end
}, {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("ibl").setup({
            indent = {
                char = "│" -- インデントガイドの文字
            },
            scope = {
                enabled = true, -- 現在のスコープを強調
                show_start = true, -- スコープの開始を表示
                show_end = false, -- スコープの終了を非表示
                char = "┃" -- スコープを示す文字
            }
        })
    end
}, {
    "lewis6991/gitsigns.nvim",
    dependencies = {"nvim-lua/plenary.nvim"}, -- 必須の依存関係
    config = function()
        require("gitsigns").setup({
            signs = {
                add = {
                    text = "│"
                }, -- 追加された行
                change = {
                    text = "│"
                }, -- 変更された行
                delete = {
                    text = "_"
                }, -- 削除された行
                topdelete = {
                    text = "‾"
                }, -- 最初の削除行
                changedelete = {
                    text = "~"
                } -- 変更後削除された行
            },
            signcolumn = true, -- Gitマーカーをサインカラムに表示
            numhl = false, -- 行番号のハイライトを無効化
            linehl = false, -- 行全体のハイライトを無効化
            watch_gitdir = {
                interval = 1000, -- Gitディレクトリの監視間隔
                follow_files = true -- ファイルの移動に追従
            },
            current_line_blame = true, -- 現在の行のGit履歴を表示
            current_line_blame_opts = {
                delay = 100, -- 履歴表示の遅延
                virt_text = true
            }
        })
    end
}, {
    'shortcuts/no-neck-pain.nvim',
    config = true -- デフォルト設定を適用
}, -- treesitter: 構文解析とハイライト
{
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- treesitter のパーサーをアップデート
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = { -- インストールする言語
            "lua", "javascript", "typescript", "python", "php", "html", "css", "json", "bash", "markdown"},
            sync_install = false, -- 同期的にパーサーをインストールするか
            auto_install = true, -- 対応している言語のファイルを開いたときに自動インストール
            highlight = {
                enable = true, -- シンタックスハイライトを有効化
                additional_vim_regex_highlighting = false -- Neovim のデフォルトハイライトを無効化
            },
            indent = {
                enable = true -- インデント機能を有効化
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gnn", -- 選択を初期化
                    node_incremental = "grn", -- ノード単位で選択範囲を広げる
                    scope_incremental = "grc", -- スコープ単位で選択範囲を広げる
                    node_decremental = "grm" -- ノード単位で選択範囲を狭める
                }
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- 次のテキストオブジェクトを予測
                    keymaps = {
                        ["af"] = "@function.outer", -- 関数全体
                        ["if"] = "@function.inner", -- 関数の中
                        ["ac"] = "@class.outer", -- クラス全体
                        ["ic"] = "@class.inner" -- クラスの中
                    }
                },
                move = {
                    enable = true,
                    set_jumps = true, -- ジャンプリストに記録
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer"
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer"
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer"
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer"
                    }
                }
            }
        })
    end
}, {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        vim.notify = notify

        -- LSPの診断メッセージも nvim-notify で表示する
        require("lspconfig.ui.windows").default_options.border = "rounded"

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded"
        })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = "rounded"
        })

        vim.diagnostic.config({
            virtual_text = true, -- バーチャルテキストを表示
            signs = true, -- サインカラム（左側のEやWアイコン）を有効化
            underline = true -- エラーのある行を下線でマーク
        })
    end
}}
