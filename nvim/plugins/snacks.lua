return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = {
        enabled = true,
        preset = {
          header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      }
      return opts
    end,
  },
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline_popup",
        opts = {
          size = {
            width = 40,
          },
          position = {
            row = "10%",
            col = "85%",
          },
          border = {
            style = "rounded",
            text = {
              top = " @_@ ",
            },
          },
        },
        format = {
          cmdline = { icon = ">" },
          search_down = { icon = "⌄" },
          search_up = { icon = "⌃" },
          filter = { icon = "$" },
          lua = { icon = "☾" },
          help = { icon = "?" },
        },
      },
      messages = {
        enabled = true,
        view = "mini",
      },
    },
  },
}
