-- Telescope
require('telescope').setup {
  pickers = {
    find_files = {
      hidden = true,
    },
    live_grep = {
      ---@diagnostic disable-next-line: unused-local
      additional_args = function(opts)
        return {
          '--hidden',
        }
      end,
    },
  },
  extensions = {
    media_files = {
      find_cmd = 'rg', -- find command (defaults to `fd`)
    },
    file_browser = {
      theme = 'ivy',
      hijack_netrw = true,
      hidden = true,
    },
  },
  defaults = {
    mappings = {
      n = {
        ['<C-q>'] = require('telescope.actions').smart_send_to_qflist,
        ['<C-x>'] = require('telescope.actions').delete_buffer,
      },
      i = {
        ['<C-q>'] = require('telescope.actions').smart_send_to_qflist,
        ['<C-x>'] = require('telescope.actions').delete_buffer,
      },
    },
  },
}

pcall(require('telescope').load_extension, 'fzf')
require('telescope').load_extension 'harpoon'
require('telescope').load_extension 'dap'
require('telescope').load_extension 'file_browser'
require('telescope').load_extension 'media_files'
