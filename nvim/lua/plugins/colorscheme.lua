return {
  -- Configure LazyVim to load gruvbox
  -- {
  --   "sainnhe/gruvbox-material",
  --   config = function()
  --     -- Optionally configure and load the colorscheme
  --     -- directly inside the plugin declaration.
  --     vim.o.background = "light"
  --     vim.g.gruvbox_material_background = "hard"
  --     vim.g.gruvbox_material_enable_italic = true
  --     -- vim.cmd.colorscheme("gruvbox-material")
  --   end,
  -- },
  { "EdenEast/nightfox.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "catppuccin-latte",
      -- colorscheme = "gruvbox-material",
      colorscheme = "dayfox",
    },
  },
}
