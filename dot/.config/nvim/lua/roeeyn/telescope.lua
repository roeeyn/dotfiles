require("telescope").setup {
    pickers = {
      find_files = {
        hidden = true
      }
    },
    defaults = {
        mappings = {
            n = {["<C-q>"] = require("telescope.actions").smart_send_to_qflist},
            i = {["<C-q>"] = require("telescope.actions").smart_send_to_qflist}
        }
    }
}
