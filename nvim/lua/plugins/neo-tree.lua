return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      enable_git_status = false,
      enable_diagnostics = false,
      default_component_configs = {
        indent = {
          expander_collapsed = "▸",
          expander_expanded = "▾",
        },
        icon = {
          folder_closed = "🗀",
          folder_open = "🗁",
          folder_empty = "🗀",
          folder_empty_open = "🗁",
        },
      },
    },
  },
}
