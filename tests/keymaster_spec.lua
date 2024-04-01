describe("keymaster", function()
	local keymaster = require("keymaster")

	before_each(function()
		keymaster.setup({
			disable_which_key = true,
			disable_legendary = true,
		})
	end)

	after_each(function()
		keymaster.shutdown()
	end)

	describe("set_keymap", function()
		it("works with a minimal argument list", function()
			local has_executed = false
			keymaster.set_keymap("n", "fx", function()
				has_executed = true
			end)
			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)
		end)

		it("sets a keymap", function()
			local has_executed = false
			keymaster.set_keymap("n", "fx", function()
				has_executed = true
			end, { desc = "TEST" })

			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)
		end)

		it("supports Which-Key-like syntax", function()
			local has_executed = false
			keymaster.set_keymap({
				f = {
					x = {
						function()
							has_executed = true
						end,
						"TEST",
					},
				},
			})

			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)
		end)

		it("supports rhs-free keymaps with Vim syntax", function()
			local notified_keymaps = {}

			---@type Observer
			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_keymaps, keymap)
				end,
			}

			keymaster.add_observer(observer)
			keymaster.set("n", "fx", nil, { desc = "Do Foo" })

			assert.are.same({ { mode = "n", lhs = "fx", rhs = nil, opts = { desc = "Do Foo" } } }, notified_keymaps)

			keymaster.remove_observer(observer)
		end)

		it("supports rhs-free keymaps with Which Key syntax", function()
			local notified_keymaps = {}

			---@type Observer
			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_keymaps, keymap)
				end,
				notify_keymap_deleted = function(_, keymap)
					for i, v in ipairs(notified_keymaps) do
						if require("keymaster.table-utils").deep_equals(v, keymap) then
							table.remove(notified_keymaps, i)
							break
						end
					end
				end,
			}

			keymaster.add_observer(observer)
			keymaster.set({ ["foo"] = "Do Foo" })

			assert.are.same({ { mode = "n", lhs = "foo", rhs = nil, opts = { desc = "Do Foo" } } }, notified_keymaps)

			keymaster.remove_observer(observer)
		end)
	end)
end)
