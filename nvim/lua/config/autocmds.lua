-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  command = "setlocal ts=2 sw=2 et",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fortran" },
  command = "setlocal ts=3 sw=3 et",
})
