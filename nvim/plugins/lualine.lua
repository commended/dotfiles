return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = {
        theme = "auto",
        component_separators = "",
        section_separators = { left = "", right = "" },
      }

      opts.sections = {
        lualine_a = {
          { "mode", icon = " ", separator = { left = "", right = "" }, padding = 2 },
        },
        lualine_b = {
          { "branch", icon = "󰘬", separator = { left = "", right = "" }, padding = 2 },
        },
        lualine_c = {
          { "filename", icon = " ", separator = { left = "", right = "" }, padding = 2 },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            function()
              return os.date("%H:%M")
            end,
            icon = " ",
            separator = { left = "", right = "" },
            padding = 2,
          },
        },
      }
    end,
  },
}
