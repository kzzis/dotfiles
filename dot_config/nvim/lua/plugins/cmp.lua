---@type LazySpec
return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")

    local closers = { "'", '"', ")", "]", "}", ">" }
    opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      else
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local next_char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
        if vim.tbl_contains(closers, next_char) then
          vim.api.nvim_win_set_cursor(0, { row, col + 1 })
        else
          fallback()
        end
      end
    end, { "i", "s" })

    opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" })

    return opts
  end,
}
