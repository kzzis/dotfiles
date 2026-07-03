---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "go",
      "c_sharp",
      "typescript",
      "javascript",
      "tsx",
    },
  },
}
