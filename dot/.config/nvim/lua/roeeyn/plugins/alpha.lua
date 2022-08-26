local M = {}

function M.setup()
	local status_ok, alpha = pcall(require, "alpha")
	if not status_ok then
		return
	end

	local dashboard = require("alpha.themes.dashboard")

	local current_path = vim.fn.getcwd()

	local lyft_header = {
		[[  ############                                       #################            ]],
		[[  ############                                    #######################         ]],
		[[  ############                                  ###########################       ]],
		[[  ############                                 #############################      ]],
		[[  ############                                ##############   ##############     ]],
		[[  ############  ############   ############# ############        ################ ]],
		[[  ############  ############   ############# ############        ################ ]],
		[[  ############  ############   ############# ##################  ################ ]],
		[[  ############  ############   ############# ##################  ################ ]],
		[[  ############  ############   ############# ##################  ############     ]],
		[[  ############  ############   ############# ##################  ############     ]],
		[[  ############  ############   ############# ##################  #############    ]],
		[[  ############  ############################ ############         ############### ]],
		[[  ############  ############################ ############          ############## ]],
		[[  ############   ########################### ###########            ############# ]],
		[[   #############  ########################## ##########                ########## ]],
		[[      ############   ######################  #######                       ###### ]],
		[[                       ###################                                        ]],
		[[                   #######################                                        ]],
		[[                   ######################                                         ]],
		[[                   ####################                                           ]],
		[[                   ################                                               ]],
	}

	local personal_header = {
		[[██████╗  ██████╗ ███████╗███████╗██╗   ██╗███╗   ██╗]],
		[[██╔══██╗██╔═══██╗██╔════╝██╔════╝╚██╗ ██╔╝████╗  ██║]],
		[[██████╔╝██║   ██║█████╗  █████╗   ╚████╔╝ ██╔██╗ ██║]],
		[[██╔══██╗██║   ██║██╔══╝  ██╔══╝    ╚██╔╝  ██║╚██╗██║]],
		[[██║  ██║╚██████╔╝███████╗███████╗   ██║   ██║ ╚████║]],
		[[╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═══╝]],
	}

	if current_path:find("roeeyn") then
		dashboard.section.header.val = personal_header
	else
		dashboard.section.header.val = lyft_header
	end

	dashboard.section.buttons.val = {
		dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
		dashboard.button(
			"h",
			"  Harpoon Files",
			":lua require('roeeyn.plugins.harpoon').open_harpoon_telescope()<CR>"
		),
		dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
		dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
	}

	local function footer()
		-- Number of plugins
		local total_plugins = #vim.tbl_keys(packer_plugins)
		local datetime = os.date("%d-%m-%Y %H:%M:%S")
		local plugins_text = "   "
			.. total_plugins
			.. " plugins"
			.. "   v"
			.. vim.version().major
			.. "."
			.. vim.version().minor
			.. "."
			.. vim.version().patch
			.. "   "
			.. datetime

		-- Quote
		local fortune = require("alpha.fortune")
		local quote = table.concat(fortune(), "\n")

		return plugins_text .. "\n" .. quote
	end

	dashboard.section.footer.val = footer()

	dashboard.section.footer.opts.hl = "Type"
	dashboard.section.header.opts.hl = "Include"
	dashboard.section.buttons.opts.hl = "Keyword"

	dashboard.opts.opts.noautocmd = true
	alpha.setup(dashboard.opts)
end

return M
