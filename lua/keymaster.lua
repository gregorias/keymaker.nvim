local M = {}
local registry = require("keymaster.registry")

--- Set up Keymaster.
---@param config table? Keymaster configuration.
M.setup = function(config)
	config = config or {}

	local main_observer = nil
	if config.which_key ~= nil then
		main_observer = require("keymaster.whichkey").WhichKeyObserver(config.which_key)
	else
		main_observer = require("keymaster.vim-keymap").VimKeymap()
	end
	registry:register_observer(main_observer)
end

--- Set a keymap using Neovim-like keymap syntax.
---
---@param rhs string | function | nil The right-hand side of the keymap or nil if it’s a info-only keymap.
---@return number id The keymap ID.
local set_vim_keymap = function(mode, lhs, rhs, opts)
	local km_keymap = require("keymaster.vim-keymap").from_vim_keymap(mode, lhs, rhs, opts)
	return registry:set_keymap(km_keymap)
end

--- Set keymaps using Which-Key-like keymap syntax.
---
---@return number[] ids The keymap IDs.
local set_which_key_keymaps = function(mappings, opts)
	opts = opts or {}
	local which_key_mappings, which_key_groups = require("keymaster.whichkey").from_wk_keymappings(mappings, opts)
	local ids = {}
	for _, mapping in ipairs(which_key_mappings) do
		local id = registry:set_keymap(mapping)
		table.insert(ids, id)
	end
	for _, group in ipairs(which_key_groups) do
		registry:set_key_group(group)
	end
	return ids
end

--- Set a keymap.
---
--- Accepts both Neovim-like keymap syntax and Which-Key-like keymap syntax.
---
---@return number | number[] id The keymap ID.
M.set_keymap = function(mappings_or_mode, wk_opts_or_lhs, rhs, opts)
	if type(mappings_or_mode) == "string" or vim.tbl_islist(mappings_or_mode) then
		return set_vim_keymap(mappings_or_mode, wk_opts_or_lhs, rhs, opts)
	else
		return set_which_key_keymaps(mappings_or_mode, wk_opts_or_lhs)
	end
end

--- Set a keymap.
--
-- An alias for `set_keymap`. Since this plugin is a replacement for
-- vim.keymap, just `set` makes sense.
M.set = M.set_keymap

--- Register a keymap.
--
-- An alias for `set_keymap`. Since this plugin is meant to work with Which Key.
M.register = M.set_keymap

--- Delete a keymap.
---
---@param keymap_id number The ID of the keymap to delete.
M.delete_keymap = function(keymap_id)
	registry:delete_keymap(keymap_id)
end

--- Get all set keymaps.
--
-- @return A table of all set keymaps.
M.get_keymaps = function()
	return registry.keymaps
end

--- Register a keymap observer.
---
---@param observer Observer
M.register_observer = function(observer)
	registry:register_observer(observer)
end

--- Unregister a keymap observer.
---
---@param observer Observer
M.unregister_observer = function(observer)
	registry:unregister_observer(observer)
end

return M
