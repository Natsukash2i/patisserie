return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        style = "moon", 
        light_style = "day",
        transparent = true,
        styles = {
            sidebars = "transparent",
        }
    },
    config = function(_, opts)
	require("tokyonight").setup(opts)
        vim.cmd[[colorscheme tokyonight-moon]]
    end,
}
