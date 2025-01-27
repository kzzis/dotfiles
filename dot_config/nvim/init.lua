-- 環境変数 LANG を英語（US）に設定
if vim.env.LANG then
    vim.env.LANG = 'en_US.UTF-8'
end

-- リーダーキーをスペースに設定
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- lazy.nvim をロード
vim.opt.rtp:prepend("~/.local/share/nvim/site/pack/lazy/start/lazy.nvim")

-- プラグインをロード
local plugins = require("plugins.plugins_config")
require('lazy').setup(plugins)

-- 基本設定
vim.opt.shell = "/bin/zsh"
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 1
vim.o.number = true
vim.cmd("syntax on")
vim.g.floaterm_shell = 'zsh'

-- キーマップ (例: Esc に 'jk' を割り当て)
-- vim.keymap.set('i', 'jk', '<Esc>')

-- カスタム関数: 新しいメモを作成
local function create_note()
    local notes_dir = "~/Documents/Notes/"
    local file_extension = ".md"
    local default_filename = os.date("%Y-%m-%d-%H-%M-%S") .. file_extension
    local filename = vim.fn.input("Enter note name (default: " .. default_filename .. "): ", default_filename)

    if filename == "" or filename == nil then
        print("Note creation cancelled.")
        return
    end

    local filepath = vim.fn.expand(notes_dir .. filename)

    if vim.fn.isdirectory(vim.fn.expand(notes_dir)) == 0 then
        vim.fn.mkdir(vim.fn.expand(notes_dir), "p")
    end

    vim.cmd("e " .. filepath)
    print("New note created: " .. filepath)
    vim.cmd("write")
end

--　ハイライト消去
vim.api.nvim_set_keymap('n', '<Leader>l', ':nohlsearch<CR>', { noremap = true, silent = true })


-- NvimTree ショートカット
vim.keymap.set('n', '<C-e>', ':NvimTreeToggle<CR>', {
    noremap = true,
    silent = true
})
vim.keymap.set('n', '<C-S-b>', ':NvimTreeFocus<CR>', {
    noremap = true,
    silent = true
})

-- telescope ショートカット
vim.keymap.set('n', '<c-p>', ':telescope find_files<cr>', {
    noremap = true,
    silent = true
})
vim.keymap.set('n', '<c-s-p>', ':telescope oldfiles<cr>', {
    noremap = true,
    silent = true
})
vim.keymap.set('n', '<c-f>', ':telescope live_grep<cr>', {
    noremap = true,
    silent = true
})
vim.keymap.set('n', '<c-s-o>', ':telescope lsp_document_symbols<cr>', {
    noremap = true,
    silent = true
})

-- Floatermのキーマッピング設定
vim.keymap.set('n', '<F12>', ':FloatermToggle<CR>', {
    noremap = true,
    silent = true
}) -- 開閉
vim.keymap.set('t', '<F12>', '<C-\\><C-n>:FloatermToggle<CR>', {
    noremap = true,
    silent = true
}) -- ターミナルモードで開閉
vim.keymap.set('n', '<leader>fn', ':FloatermNew<CR>', {
    noremap = true,
    silent = true
}) -- 新しいターミナルを作成
vim.keymap.set('t', '<leader>fn', '<C-\\><C-n>:FloatermNew<CR>', {
    noremap = true,
    silent = true
}) -- ターミナルモードで新規作成
vim.keymap.set('n', '<leader>fl', ':FloatermNext<CR>', {
    noremap = true,
    silent = true
}) -- 次のターミナルに移動
vim.keymap.set('n', '<leader>fp', ':FloatermPrev<CR>', {
    noremap = true,
    silent = true
}) -- 前のターミナルに移動
vim.keymap.set('n', '<leader>fc', ':FloatermKill<CR>', {
    noremap = true,
    silent = true
}) -- 現在のターミナルを閉じる

-- ファイルの再読み込み（通常）
vim.api.nvim_set_keymap('n', '<leader>r', ':e<CR>', {
    noremap = true,
    silent = true
})

-- ファイルの再読み込み（変更を破棄して強制）
vim.api.nvim_set_keymap('n', '<leader>R', ':e!<CR>', {
    noremap = true,
    silent = true
})

-- ファイルを保存時に自動フォーマット
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.lsp.buf.format({
            async = false
        })
    end
})

local map = vim.keymap.set

-- 入力時に自動保存する設定
vim.api.nvim_create_autocmd({"InsertLeave"}, {
    pattern = {"*.js", "*.jsx", "*.ts", "*.tsx", "*.go", "*.rs", "*.py", "*.php", "*.html", "*.css", "*.scss", "*.md",
               "*.json"},
    callback = function()
        if vim.bo.modified then
            vim.cmd("silent write")
        end
    end
})
