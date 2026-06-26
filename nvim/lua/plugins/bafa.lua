return {
    "mistweaverco/bafa.nvim",
    version = "v1.11.0",
    keys = {
        {
            "<leader>b",
            function()
                require("bafa").toggle({ with_jump_labels = true })
            end,
            desc = "Open buffer manager",
        },
    },
}
