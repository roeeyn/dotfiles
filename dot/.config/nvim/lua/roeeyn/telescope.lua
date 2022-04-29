require("telescope").setup {
    pickers = {
      find_files = {
        hidden = true
      }
    },
    defaults = {
        mappings = {
            n = {
              ["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
              ["<C-x>"] = require("telescope.actions").delete_buffer,
            },
            i = {
              ["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
              ["<C-x>"] = require("telescope.actions").delete_buffer,
            }
        }
    }
}

require("telescope").load_extension("git_worktree")
require("telescope").load_extension("dap")
