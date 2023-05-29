-- Telescope
require('telescope').setup {
  pickers = {
    find_files = {
      hidden = true,
      -- As defined in: https://github.com/nvim-telescope/telescope.nvim/blob/6d3fbffe426794296a77bb0b37b6ae0f4f14f807/lua/telescope/builtin/__files.lua#L243
      find_cmd = { 'rg', '--files', '--color', 'never', '--ignore-file', '~/.ignore' },
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
  },
  defaults = {
    dynamic_preview_title = true,
    file_ignore_patterns = {
      '.git/',
    },
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
require('telescope').load_extension 'media_files'
