--- The keymap dispatcher, which serves as an observable facade for keymap operations.
---
--- TODO: Stop using a singleton like this.
---
--- KeymapDispatcher is a singleton object that forwards all the keymap
--- operations to its observers.
---
--- This object is purposefully simple in that has a single responsibility: to
--- notify all observers of keymap operations. The simplicity of this object
--- enables flexible extension points for the keymap system and avoids the
--- complexity of managing keymap state.
---
---@class KeymapDispatcher
local KeymapDispatcher = {
	observers = {},
}

--- Keymaster keymap.
---
--- It is specifically designed to be a natural extension of the vim.keymap.set interface.
---
--- If rhs is missing, then this keymap is considered to be for information
--- only, not to be bound.
---
---@class (exact) KeymasterKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | function | nil
---@field opts KeymasterKeymapOpts

--- Keymaster keymap options.
---
--- They can contain arbitrary key-value pairs.
---
---@class KeymasterKeymapOpts: VimKeymapOpts

--- Keymaster key group.
---
---@class (exact) KeymasterKeyGroup
---@field mode string | string[]
---@field lhs string
---@field opts { name: string, buffer: number? }

---@class Observer
---@field notify_keymap_set fun(self, keymap: KeymasterKeymap): nil
---@field notify_keymap_deleted (fun(self, keymap: KeymasterKeymap): nil)?
---@field notify_key_group_set (fun(self, keymap: KeymasterKeyGroup): nil)?

--- Register an observer.
---
---@param observer Observer
function KeymapDispatcher:add_observer(observer)
	table.insert(self.observers, observer)
end

--- Unregister an observer.
---
---@param observer Observer
function KeymapDispatcher:remove_observer(observer)
	for i, v in pairs(self.observers) do
		if v == observer then
			table.remove(self.observers, i)
			break
		end
	end
end

--- Set a keymap.
---
---@param keymap KeymasterKeymap
---@return nil
function KeymapDispatcher:set_keymap(keymap)
	for _, observer in pairs(self.observers) do
		observer:notify_keymap_set(keymap)
	end
end

--- Delete a keymap.
---
---@param keymap KeymasterKeymap
---@return nil
function KeymapDispatcher:delete_keymap(keymap)
	for _, observer in pairs(self.observers) do
		if observer.notify_keymap_deleted then
			observer:notify_keymap_deleted(keymap)
		end
	end
end

--- Set a key group.
---
---@param key_group KeymasterKeyGroup
---@return nil
function KeymapDispatcher:set_key_group(key_group)
	for _, observer in pairs(self.observers) do
		if observer.notify_key_group_set then
			observer:notify_key_group_set(key_group)
		end
	end
end

--- Delete a key group.
---
---@param key_group KeymasterKeyGroup
---@return nil
function KeymapDispatcher:delete_key_group(key_group)
	for _, observer in pairs(self.observers) do
		if observer.notify_key_group_deleted then
			observer:notify_key_group_deleted(key_group)
		end
	end
end

return KeymapDispatcher