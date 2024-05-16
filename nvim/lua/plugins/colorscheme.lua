return {
  -- Configure LazyVim to load gruvbox
  { "ellisonleao/gruvbox.nvim", opts = { contrast = "hard" } },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "catppuccin-latte",
      colorscheme = "gruvbox",
    },
  },
}
