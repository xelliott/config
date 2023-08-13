return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local icons = require("lazyvim.config").icons

      table.insert(opts.sections.lualine_x, "encoding")
      table.insert(opts.sections.lualine_x, "fileformat")
      opts.sections.lualine_z = opts.sections.lualine_y
      opts.sections.lualine_y = {}
      opts.sections.lualine_b = {}

      local lualine_c = opts.sections.lualine_c
      for i, section in ipairs(lualine_c) do
        if type(section) == "table" and section[1] == "filename" then
          table.remove(lualine_c, i)
          break
        end
      end

      opts.winbar = {
        lualine_c = {
          {
            'filename',
            path = 1,
          }
        },
        lualine_y = {
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_z = { 'branch' },
      }
    end,
  },
}
