return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    },
    opts = {
      defaults = {
        layout_strategy = "center",
        layout_config = {
          center = {
            width = 0.6,
            height = 0.5,
          },
        },
      },
    },
  },
}
