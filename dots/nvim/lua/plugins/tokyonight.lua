return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "moon",
    transparent = true,
    styles = {
      sidebars = "transparent",
    },
    on_highlights = function(hl, c)
      local bright_color = "#8282A9"

      hl.LineNr = { fg = bright_color }
      hl.LineNrAbove = { fg = bright_color }
      hl.LineNrBelow = { fg = bright_color }
      hl.CursorLineNr = { fg = c.orange, bold = true }
    end,
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd([[colorscheme tokyonight-moon]])
  end,
}
