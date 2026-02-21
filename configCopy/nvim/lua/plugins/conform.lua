return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      cpp = { "clang_format" },
      c = { "clang_format" },
      python = { "ruff_format" },
    },
    formatters = {
      clang_format = {
        prepend_args = { "--style={BasedOnStyle: LLVM, PointerAlignment: Left, ReferenceAlignment: Left}" },
      },
    },
  },
}
