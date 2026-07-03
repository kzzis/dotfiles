---@type LazySpec
return {
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  {
    "rcarriga/nvim-notify",
    opts = { background_colour = "#1e1e2e" },
  },

  {
    "goolord/alpha-nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "MaximilianLloyd/ascii.nvim",
    },
    opts = function(_, opts)
      opts.section.header.val = require("ascii").art.text.neovim.default1

      local get_icon = require("astroui").get_icon
      table.insert(opts.section.buttons.val, opts.button("LDR e", get_icon("FolderOpen", 2, true) .. "Files (oil)  "))
      table.insert(
        opts.section.buttons.val,
        opts.button("LDR E", get_icon("FolderClosed", 2, true) .. "Explorer (neo-tree)  ")
      )

      return opts
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
      require("luasnip").filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts)
    end,
  },

  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end,
  },

  {
    "esmuellert/codediff.nvim",
    config = function() require("codediff").setup() end,
  },

  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol_text",
      preset = "codicons",
      symbol_map = {
        Text = "📝",
        Method = "🔧",
        Function = "⚡",
        Constructor = "🏗",
        Field = "🌱",
        Variable = "💡",
        Class = "🏛",
        Interface = "🔌",
        Module = "📦",
        Property = "🔑",
        Unit = "📏",
        Value = "🎯",
        Enum = "🎲",
        Keyword = "🔑",
        Snippet = "✂",
        Color = "🎨",
        File = "📄",
        Reference = "🔗",
        Folder = "📁",
        EnumMember = "🔢",
        Constant = "⚓",
        Struct = "🏗",
        Event = "🎉",
        Operator = "➕",
        TypeParameter = "📌",
      },
    },
  },
}
