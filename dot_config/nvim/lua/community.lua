-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.
---@type LazySpec
return {"AstroNvim/astrocommunity", {{
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- colorscheme を最優先でロード
    config = function()
        vim.cmd("colorscheme gruvbox")
    end
} -- import/override with your plugins folder
}}
