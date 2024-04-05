-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "c", "cpp", "cuda" },
--   command = "setlocal ts=2 sw=2 et",
-- })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "cuda" },
  callback = function(ev)
      vim.bo[ev.buf].commentstring = "// %s"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fortran" },
  command = "setlocal ts=3 sw=3 et | let b:fortran_do_enddo=1 | let b:fortran_indent_less=1",
})
