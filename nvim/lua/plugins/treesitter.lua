return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c", "cpp" })
        vim.list_extend(opts.ensure_installed, { "fortran" })
        vim.list_extend(opts.ensure_installed, { "julia" })
        vim.list_extend(opts.ensure_installed, { "toml" })
      end
    end,
  },
}
