if vim.g.snippets ~= "luasnip" then
	return
end

local ls = require("luasnip")
local types = require("luasnip.util.types")

ls.config.set_config({

	-- This tells LuaSnip to remember to keep around the last snippet
	-- You can jump back into it even if you move outside the selection
	history = true,

	-- this one is cool cause if you have dynamic snippets, it updates as you type
	update_events = "TextChanged,TextChangedI",

	-- Autosnippets
	enable_autosnippets = true,

	-- Crazy highlights!
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "<-", "Error" } },
			},
		},
	},
})

require("luasnip/loaders/from_vscode").load()

-- Completion
vim.keymap.set("i", "<C-k>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end)

vim.keymap.set("i", "<C-j>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end)

vim.keymap.set("i", "<C-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
