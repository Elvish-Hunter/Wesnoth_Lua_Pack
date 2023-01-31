local helper = wesnoth.require "lua/helper.lua"
local wlp_utils = wesnoth.require "~add-ons/Wesnoth_Lua_Pack/wlp_utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- metatable for GUI tags
local T = wml.tag

-- support for translatable strings, custom textdomain
local _ = wesnoth.textdomain "wesnoth-Wesnoth_Lua_Pack"
-- #textdomain wesnoth-Wesnoth_Lua_Pack

-- [show_quick_debug]
-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
-- It allows modifying all those unit parameters that don't require accessing the .__cfg field.
-- Shows also read only parameters.
-- Usage:
-- [set_menu_item]
--	id=quick_debug
--	description=Quick Debug
--	[command]
--		[show_quick_debug]
--		[/show_quick_debug]
--	[/command]
-- [/set_menu_item]

function wml_actions.show_quick_debug ( cfg )
	-- acquire unit with units.find_on_map, if unit.valid show dialog
	local lua_dialog_unit = wesnoth.units.find_on_map ( { x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1 } )[1] -- clearly, at x1,y1 there could be only one unit
	local oversize_factor = 10 -- make it possible to increase over unit.max_attacks; no idea what would be a sensible value
	if lua_dialog_unit and lua_dialog_unit.valid then -- to avoid indexing a nil value
		local dialog_wml = wml.load "~add-ons/Wesnoth_Lua_Pack/gui/quick_debug.cfg"
		local debug_dialog = wml.get_child(dialog_wml, 'resolution')

		local temp_table = { } -- to store values before checking if user allowed modifying

		local function preshow(dialog)
			-- here set all widget starting values
			-- set slider bounds
			dialog.unit_level_slider.min_value = math.min( 0, lua_dialog_unit.level )
			dialog.unit_level_slider.max_value = math.max( 5, lua_dialog_unit.level )
			dialog.unit_side_slider.max_value = math.max( 2, #wesnoth.sides ) -- to avoid crash if there is only one side
			dialog.unit_hitpoints_slider.min_value = math.min(0, lua_dialog_unit.hitpoints)
			dialog.unit_hitpoints_slider.max_value = math.max(lua_dialog_unit.max_hitpoints * oversize_factor, lua_dialog_unit.hitpoints)
			dialog.unit_experience_slider.min_value = math.min(0, lua_dialog_unit.experience)
			dialog.unit_experience_slider.max_value = math.max(lua_dialog_unit.max_experience * oversize_factor, lua_dialog_unit.experience)
			-- to avoid crashing if max_moves == 0
			dialog.unit_moves_slider.max_value = math.max(1, lua_dialog_unit.max_moves * oversize_factor, lua_dialog_unit.moves)
			-- to avoid crashing if unit has max_attacks == 0
			dialog.unit_attacks_slider.max_value = math.max(1, lua_dialog_unit.max_attacks * oversize_factor, lua_dialog_unit.attacks_left)
			-- set read_only labels
			dialog.unit_id.label = lua_dialog_unit.id
			dialog.unit_valid.label = lua_dialog_unit.valid
			dialog.unit_type.label = lua_dialog_unit.type
			dialog.unit_canrecruit.label = lua_dialog_unit.canrecruit
			dialog.unit_race.label = lua_dialog_unit.race
			dialog.unit_cost.label = lua_dialog_unit.cost
			dialog.unit_image.label = string.format("%s~TC(%d,magenta)", lua_dialog_unit.__cfg.image or "", lua_dialog_unit.side)
			-- set location form
			dialog.textbox_loc_x.text = lua_dialog_unit.x
			dialog.textbox_loc_y.text = lua_dialog_unit.y
			-- set sliders
			dialog.unit_level_slider.value = lua_dialog_unit.level
			dialog.unit_side_slider.value = lua_dialog_unit.side
			dialog.unit_hitpoints_slider.value = lua_dialog_unit.hitpoints
			dialog.unit_experience_slider.value = lua_dialog_unit.experience
			dialog.unit_moves_slider.value = lua_dialog_unit.moves
			dialog.unit_attacks_slider.value = lua_dialog_unit.attacks_left
			-- set upkeep
			local upkeep = lua_dialog_unit.upkeep
			if upkeep == "loyal" or upkeep == "free" then
				dialog.upkeep_listbox.selected_index = 1
				dialog.upkeep_slider.enabled = false
			elseif upkeep == "full" then
				dialog.upkeep_listbox.selected_index = 2
				dialog.upkeep_slider.enabled = false
			else
				dialog.upkeep_listbox.selected_index = 3
				dialog.upkeep_slider.value = tonumber(upkeep)
			end

			-- the slider becomes active only if the upkeep becomes a numerical value
			local function upkeep_cb()
				if dialog.upkeep_listbox.selected_index == 3 then
					dialog.upkeep_slider.enabled = true
				else
					dialog.upkeep_slider.enabled = false
				end
			end
			dialog.upkeep_listbox.on_modified = upkeep_cb

			-- set textboxes
			dialog.textbox_name.text = tostring(lua_dialog_unit.name)
			dialog.textbox_extra_recruit.text = table.concat( lua_dialog_unit.extra_recruit, "," )
			dialog.textbox_advances_to.text = table.concat( lua_dialog_unit.advances_to, "," )
			dialog.textbox_role.text = lua_dialog_unit.role
			-- set checkbuttons
			dialog.poisoned_checkbutton.selected = lua_dialog_unit.status.poisoned
			dialog.slowed_checkbutton.selected = lua_dialog_unit.status.slowed
			dialog.petrified_checkbutton.selected = lua_dialog_unit.status.petrified
			dialog.invulnerable_checkbutton.selected = lua_dialog_unit.status.invulnerable
			dialog.uncovered_checkbutton.selected = lua_dialog_unit.status.uncovered
			dialog.guardian_checkbutton.selected = lua_dialog_unit.status.guardian
			dialog.unhealable_checkbutton.selected = lua_dialog_unit.status.unhealable
			dialog.stunned_checkbutton.selected = lua_dialog_unit.status.stunned
			-- set radiobutton for alignment
			local temp_alignment
			if lua_dialog_unit.alignment == "lawful" then temp_alignment = 1
			elseif lua_dialog_unit.alignment == "neutral" then temp_alignment = 2
			elseif lua_dialog_unit.alignment == "chaotic" then temp_alignment = 3
			elseif lua_dialog_unit.alignment == "liminal" then temp_alignment = 4
			end
			dialog.alignment_listbox.selected_index = temp_alignment
			-- set radiobutton for facing
			local temp_facing
			if lua_dialog_unit.facing == "nw" then temp_facing = 1
			elseif lua_dialog_unit.facing == "ne" then temp_facing = 2
			elseif lua_dialog_unit.facing == "n" then temp_facing = 3
			elseif lua_dialog_unit.facing == "sw" then temp_facing = 4
			elseif lua_dialog_unit.facing == "se" then temp_facing = 5
			elseif lua_dialog_unit.facing == "s" then temp_facing = 6
			end
			dialog.facing_listbox.selected_index = temp_facing
			-- other checkbuttons
			dialog.resting_checkbutton.selected = lua_dialog_unit.resting
			dialog.hidden_checkbutton.selected = lua_dialog_unit.hidden
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow(dialog)
				-- here get all the widget values in variables; store them in temp variables
				-- location form; it requires a validation procedure
				local new_x, new_y
				new_x = tonumber(dialog.textbox_loc_x.text)
				new_y = tonumber(dialog.textbox_loc_y.text)
				local width = wesnoth.current.map.playable_width
				local height = wesnoth.current.map.playable_height
				local border = wesnoth.current.map.border_size

				if (not new_x) or (new_x < 1) or (new_x > width) then
					wesnoth.log("wml", "Invalid X location input in [show_quick_debug], ignoring")
				else
					temp_table.x = new_x
				end

				if (not new_y) or (new_y < 1) or (new_y > height) then
					wesnoth.log("wml", "Invalid Y location input in [show_quick_debug], ignoring")
				else
					temp_table.y = new_y
				end

				-- upkeep
				local upkeep_type = dialog.upkeep_listbox.selected_index
				if upkeep_type == 1 then
					temp_table.upkeep = "loyal"
				elseif upkeep_type == 2 then
					temp_table.upkeep = "full"
				elseif upkeep_type == 3 then
					temp_table.upkeep = dialog.upkeep_slider.value
				end

				-- sliders
				temp_table.level = dialog.unit_level_slider.value
				temp_table.side = dialog.unit_side_slider.value
				temp_table.hitpoints = dialog.unit_hitpoints_slider.value
				temp_table.experience = dialog.unit_experience_slider.value
				temp_table.moves = dialog.unit_moves_slider.value
				temp_table.attacks_left = dialog.unit_attacks_slider.value
				-- text boxes
				temp_table.name = dialog.textbox_name.text
				temp_table.advances_to = dialog.textbox_advances_to.text
				temp_table.extra_recruit = dialog.textbox_extra_recruit.text
				temp_table.role = dialog.textbox_role.text
				-- checkbuttons
				temp_table.poisoned = dialog.poisoned_checkbutton.selected
				temp_table.slowed = dialog.slowed_checkbutton.selected
				temp_table.petrified = dialog.petrified_checkbutton.selected
				temp_table.invulnerable = dialog.invulnerable_checkbutton.selected
				temp_table.uncovered = dialog.uncovered_checkbutton.selected
				temp_table.guardian = dialog.guardian_checkbutton.selected
				temp_table.unhealable = dialog.unhealable_checkbutton.selected
				temp_table.stunned = dialog.stunned_checkbutton.selected
				-- alignment radiobutton
				local alignments = { "lawful", "neutral", "chaotic", "liminal" }
				temp_table.alignment = alignments[ dialog.alignment_listbox.selected_index ]
				-- put facing here
				local facings = { "nw", "ne", "n", "sw", "se", "s" }
				-- dialog.facing_listbox.selected_index returns a number, that was 2 for the second radiobutton and 5 for the fifth, hence the table above
				temp_table.facing = facings[ dialog.facing_listbox.selected_index ] -- it is setted correctly, but for some reason it is not shown
				-- misc checkbuttons
				temp_table.resting = dialog.resting_checkbutton.selected
				temp_table.hidden = dialog.hidden_checkbutton.selected
			end

			local return_value = gui.show_dialog( debug_dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end

		local return_table = wesnoth.sync.evaluate_single(sync)
		local return_value = return_table.return_value
		local temp_table = wml.get_child( return_table, "temp_table" )

		if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter, modify unit
			-- location form
			-- setting these values doesn't have any effect if the final location
			-- is occupied by another unit, at least in 1.14
			if temp_table.x and temp_table.y then
				lua_dialog_unit.loc = {temp_table.x, temp_table.y}
			elseif temp_table.x then
				lua_dialog_unit.x = temp_table.x
			elseif temp_table.y then
				lua_dialog_unit.y = temp_table.y
			end

			lua_dialog_unit.upkeep = temp_table.upkeep
			-- sliders
			lua_dialog_unit.level = temp_table.level
			if wesnoth.sides[temp_table.side] then
				lua_dialog_unit.side = temp_table.side
			end
			lua_dialog_unit.hitpoints = temp_table.hitpoints
			lua_dialog_unit.experience = temp_table.experience
			lua_dialog_unit.moves = temp_table.moves
			lua_dialog_unit.attacks_left = temp_table.attacks_left
			-- text boxes
			lua_dialog_unit.name = temp_table.name
			-- we do this empty table/gmatch/insert cycle, the .text attribute of a text_box returns a string, and the value required is a "table with unnamed indices holding strings"
			-- moved here because wesnoth.sync.evaluate_single needs a WML object, and a table with unnamed indices isn't
			local temp_advances_to = {}
			local temp_extra_recruit = {}
			for value in wlp_utils.split( temp_table.extra_recruit ) do
				table.insert( temp_extra_recruit, wlp_utils.chop( value ) )
			end
			for value in wlp_utils.split( temp_table.advances_to ) do
				table.insert( temp_advances_to, wlp_utils.chop( value ) )
			end
			lua_dialog_unit.advances_to = temp_advances_to
			lua_dialog_unit.extra_recruit = temp_extra_recruit
			lua_dialog_unit.role = temp_table.role
			-- checkbuttons
			lua_dialog_unit.status.poisoned = temp_table.poisoned
			lua_dialog_unit.status.slowed = temp_table.slowed
			lua_dialog_unit.status.petrified = temp_table.petrified
			lua_dialog_unit.status.invulnerable = temp_table.invulnerable
			lua_dialog_unit.status.uncovered = temp_table.uncovered
			lua_dialog_unit.status.guardian = temp_table.guardian
			lua_dialog_unit.status.unhealable = temp_table.unhealable
			lua_dialog_unit.status.stunned = temp_table.stunned
			lua_dialog_unit.alignment = temp_table.alignment
			lua_dialog_unit.facing = temp_table.facing
			-- misc; checkbuttons
			lua_dialog_unit.resting = temp_table.resting
			lua_dialog_unit.hidden = temp_table.hidden
			-- for some reason, without this delay the death animation isn't played
			wesnoth.interface.delay(1)
			-- fire events if needed
			if lua_dialog_unit.hitpoints <= 0 then -- do not try to advance a dead unit
				wml_actions.kill( { id = lua_dialog_unit.id, animate = true, fire_event = true } )
			elseif lua_dialog_unit.experience >= lua_dialog_unit.max_experience then
				wml_actions.store_unit { { "filter", { id = lua_dialog_unit.id } }, variable = "Lua_store_unit", kill = true }
				wml_actions.unstore_unit { variable = "Lua_store_unit", find_vacant = false, advance = true, fire_event = true }
				wml.variables["Lua_store_unit"] = nil
			end
			-- finally, redraw to be sure of showing changes
			wml_actions.redraw {}
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.interface.add_chat_message( tostring( _"Quick Debug" ), tostring( _"Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
	-- if user clicks on empty hex, do nothing
	end
end

-- [show_side_debug]
-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
-- It allows modifying all those side parameters that don't require accessing the .__cfg field.
-- Shows also read only parameters.
-- Usage:
-- [set_menu_item]
--	id=side_debug
--	description=Side Debug
--	[command]
--		[show_side_debug]
--		[/show_side_debug]
--	[/command]
-- [/set_menu_item]

function wml_actions.show_side_debug ( cfg )
	local side_unit = wesnoth.units.find_on_map ( { x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1 } )[1]
	if side_unit and side_unit.valid then
		local side_number = side_unit.side -- clearly, at x1,y1 there could be only one unit

		local lua_dialog_side = wesnoth.sides[side_number]
		
		local dialog_wml = wml.load "~add-ons/Wesnoth_Lua_Pack/gui/side_debug.cfg"
		local side_dialog = wml.get_child(dialog_wml, 'resolution')

		local function preshow(dialog)
			-- set slider bounds
			dialog.side_gold_slider.min_value = math.min( 0, lua_dialog_side.gold )
			dialog.side_gold_slider.max_value = math.max( 1000, lua_dialog_side.gold )
			dialog.side_village_gold_slider.min_value = math.min( 0, lua_dialog_side.village_gold )
			dialog.side_village_gold_slider.max_value = math.max( 10, lua_dialog_side.village_gold )
			dialog.side_village_support_slider.min_value = math.min( 0, lua_dialog_side.village_support )
			dialog.side_village_support_slider.max_value = math.max( 10, lua_dialog_side.village_support )
			dialog.side_base_income_slider.min_value = math.min( -2, lua_dialog_side.base_income )
			dialog.side_base_income_slider.max_value = math.max( 18, lua_dialog_side.base_income )
			-- set widget values
			-- read-only labels
			dialog.side_number_label.label = lua_dialog_side.side
			dialog.total_income_label.label = lua_dialog_side.total_income
			dialog.name_label.label = lua_dialog_side.side_name
			dialog.faction_label.label = lua_dialog_side.faction
			dialog.faction_name_label.label = lua_dialog_side.faction_name
			dialog.is_local_label.label = lua_dialog_side.is_local
			dialog.share_maps_label.label = lua_dialog_side.share_maps
			dialog.share_view_label.label = lua_dialog_side.share_view
			dialog.num_units_label.label = lua_dialog_side.num_units
			dialog.num_villages_label.label = lua_dialog_side.num_villages
			dialog.total_upkeep_label.label = lua_dialog_side.total_upkeep
			dialog.expenses_label.label = lua_dialog_side.expenses
			dialog.net_income_label.label = lua_dialog_side.net_income
			dialog.chose_random_label.label = lua_dialog_side.chose_random

			if lua_dialog_side.flag_icon == "" then
				dialog.flag_image.label = string.format( "flags/flag-icon.png~RC(flag_green>%s)", lua_dialog_side.color )
			else
				dialog.flag_image.label = string.format( "%s~RC(flag_green>%s)", lua_dialog_side.flag_icon, lua_dialog_side.color )
			end

			-- sliders
			dialog.side_gold_slider.value = lua_dialog_side.gold
			dialog.side_village_gold_slider.value = lua_dialog_side.village_gold
			dialog.side_base_income_slider.value = lua_dialog_side.base_income
			dialog.side_village_support_slider.value = lua_dialog_side.village_support
			-- text boxes
			--dialog.side_objectives_textbox.text = tostring(lua_dialog_side.objectives)
			dialog.user_team_name_textbox.text = tostring(lua_dialog_side.user_team_name)
			dialog.team_name_textbox.text = lua_dialog_side.team_name
			dialog.side_color_textbox.text = lua_dialog_side.color
			dialog.recruit_textbox.text = table.concat( lua_dialog_side.recruit, "," )
			dialog.flag_icon_textbox.text = lua_dialog_side.flag_icon
			-- checkbuttons
			dialog.objectives_changed_checkbutton.selected = lua_dialog_side.objectives_changed
			dialog.scroll_to_leader_checkbutton.selected = lua_dialog_side.scroll_to_leader
			dialog.shroud_checkbutton.selected = lua_dialog_side.shroud
			dialog.persistent_checkbutton.selected = lua_dialog_side.persistent
			dialog.hidden_checkbutton.selected = lua_dialog_side.hidden
			dialog.lost_checkbutton.selected = lua_dialog_side.lost
			dialog.fog_checkbutton.selected = lua_dialog_side.fog
			dialog.end_turn_checkbutton.selected = lua_dialog_side.suppress_end_turn_confirmation
			-- radiobuttons
			local temp_controller

			if lua_dialog_side.controller == "ai" then
				temp_controller = 1
			elseif lua_dialog_side.controller == "human" then
				temp_controller = 2
			elseif lua_dialog_side.controller == "null" then
				temp_controller = 3
			end
			dialog.controller_listbox.selected_index = temp_controller

			if lua_dialog_side.defeat_condition == "no_leader_left" then
				dialog.defeat_condition_listbox.selected_index = 1
			elseif lua_dialog_side.defeat_condition == "no_units_left" then
				dialog.defeat_condition_listbox.selected_index = 2
			elseif lua_dialog_side.defeat_condition == "never" then
				dialog.defeat_condition_listbox.selected_index = 3
			elseif lua_dialog_side.defeat_condition == "always" then
				dialog.defeat_condition_listbox.selected_index = 4
			end

			if lua_dialog_side.share_vision == "all" then
				dialog.share_vision_listbox.selected_index = 1
			elseif lua_dialog_side.share_vision == "shroud" then
				dialog.share_vision_listbox.selected_index = 2
			elseif lua_dialog_side.share_vision == "none" then
				dialog.share_vision_listbox.selected_index = 3
			end
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow(dialog)
				-- get widget values
				-- sliders
				temp_table.gold = dialog.side_gold_slider.value
				temp_table.village_gold = dialog.side_village_gold_slider.value
				temp_table.base_income = dialog.side_base_income_slider.value
				temp_table.village_support = dialog.side_village_support_slider.value
				-- text boxes
				temp_table.user_team_name = dialog.user_team_name_textbox.text
				temp_table.team_name = dialog.team_name_textbox.text
				temp_table.recruit = dialog.recruit_textbox.text
				temp_table.color = dialog.side_color_textbox.text
				temp_table.flag_icon = dialog.flag_icon_textbox.text
				-- checkbuttons
				temp_table.objectives_changed = dialog.objectives_changed_checkbutton.selected
				temp_table.scroll_to_leader = dialog.scroll_to_leader_checkbutton.selected
				temp_table.shroud = dialog.shroud_checkbutton.selected
				temp_table.persistent = dialog.persistent_checkbutton.selected
				temp_table.hidden = dialog.hidden_checkbutton.selected
				temp_table.lost = dialog.lost_checkbutton.selected
				temp_table.fog = dialog.fog_checkbutton.selected
				temp_table.suppress_end_turn_confirmation = dialog.end_turn_checkbutton.selected
				-- radiobuttons
				local controllers = { "ai", "human", "null" }
				temp_table.controller = controllers[ dialog.controller_listbox.selected_index ]

				local defeat_conditions = { "no_leader_left", "no_units_left", "never", "always" }
				temp_table.defeat_condition = defeat_conditions[ dialog.defeat_condition_listbox.selected_index ]

				local share_vision = { "all", "shroud", "none" }
				temp_table.share_vision = share_vision[ dialog.share_vision_listbox.selected_index ]
			end

			local return_value = gui.show_dialog( side_dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end
		local return_table = wesnoth.sync.evaluate_single(sync)
		local return_value = return_table.return_value
		local temp_table = wml.get_child(return_table, "temp_table")

		if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter, modify unit
			lua_dialog_side.gold = temp_table.gold
			lua_dialog_side.village_gold = temp_table.village_gold
			lua_dialog_side.village_support = temp_table.village_support
			lua_dialog_side.base_income = temp_table.base_income
			lua_dialog_side.user_team_name = temp_table.user_team_name
			lua_dialog_side.team_name = temp_table.team_name
			lua_dialog_side.objectives_changed = temp_table.objectives_changed
			lua_dialog_side.scroll_to_leader = temp_table.scroll_to_leader
			lua_dialog_side.hidden = temp_table.hidden
			lua_dialog_side.lost = temp_table.lost
			lua_dialog_side.shroud = temp_table.shroud
			lua_dialog_side.fog = temp_table.fog
			lua_dialog_side.persistent = temp_table.persistent
			lua_dialog_side.suppress_end_turn_confirmation = temp_table.suppress_end_turn_confirmation
			lua_dialog_side.controller = temp_table.controller
			lua_dialog_side.defeat_condition = temp_table.defeat_condition
			lua_dialog_side.share_vision = temp_table.share_vision
			lua_dialog_side.color = temp_table.color
			lua_dialog_side.flag_icon = temp_table.flag_icon

			local temp_recruit = {}
			for value in wlp_utils.split( temp_table.recruit ) do
				table.insert( temp_recruit, wlp_utils.chop( value ) )
			end
			lua_dialog_side.recruit = temp_recruit
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.interface.add_chat_message( tostring( _"Side Debug" ), tostring( _"Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
		-- if user clicks on empty hex, do nothing
	end
end

-- [item_dialog]
-- an alternative interface to pick items
-- could be used in place of [message] with [option] tags
function wml_actions.item_dialog( cfg )
	local dialog_wml = wml.load "~add-ons/Wesnoth_Lua_Pack/gui/item_dialog.cfg"
	local item_dialog = wml.get_child(dialog_wml, 'resolution')

	local function item_preshow(dialog)
		-- here set all widget starting values
		dialog.item_description.use_markup = true
		dialog.item_effect.use_markup = true
		dialog.item_name.label = cfg.name or ""
		dialog.image_name.label = cfg.image or ""
		dialog.item_description.label = cfg.description or ""
		dialog.item_effect.label = cfg.effect or ""
		dialog.take_button.label = cfg.take_string or wml.error( "Missing take_string= key in [item_dialog]" )
		dialog.leave_button.label = cfg.leave_string or wml.error( "Missing leave_string= key in [item_dialog]" )
	end

	local function sync()
		local function item_postshow(dialog)
			-- here get all widget values
		end

		local return_value = gui.show_dialog( item_dialog, item_preshow, item_postshow )

		return { return_value = return_value }
	end

	local return_table = wesnoth.sync.evaluate_single(sync)
	if return_table.return_value == 1 or return_table.return_value == -1 then
		wml.variables[cfg.variable or "item_picked"] = "yes"
	else wml.variables[cfg.variable or "item_picked"] = "no"
	end
end

-- the three tags below are WML/Lua remakes of Javascript's standard dialogs alert(), confirm() and prompt()
function wml_actions.alert( cfg )
	if cfg.title then
		gui.alert(cfg.title, cfg.message)
	else
		gui.alert(cfg.message)
	end
end

function wml_actions.confirm( cfg )
	local variable = cfg.variable or wml.error( "Missing variable= key in [confirm]" )

	local function sync()
		if cfg.title then
			return { return_value = gui.confirm(cfg.title, cfg.message) }
		else
			return { return_value = gui.confirm(cfg.message) }
		end
	end

	local return_table = wesnoth.sync.evaluate_single(sync)
	wml.variables[variable] = return_table.return_value
end

function wml_actions.prompt( cfg )
	local variable = cfg.variable or wml.error( "Missing variable= key in [prompt]" )
	local dialog_wml = wml.load "~add-ons/Wesnoth_Lua_Pack/gui/prompt.cfg"
	local prompt_dialog = wml.get_child(dialog_wml, 'resolution')

	local function preshow(dialog)
		-- here set all widget starting values
		dialog.message.use_markup = true
		dialog.title.label = cfg.title or ""
		dialog.message.label = cfg.message or ""
		-- in 1.15.x, setting a translatable string as value of a text box
		-- widget raises an error; handle this case
		if cfg.text then
			dialog.text.text = tostring(cfg.text)
		end
	end

	local function sync()
		local input

		local function postshow(dialog)
			-- here get all widget values
			input = dialog.text.text
		end

		local return_value = gui.show_dialog( prompt_dialog, preshow, postshow )
		return { return_value = return_value, input = input }
	end

	local return_table = wesnoth.sync.evaluate_single(sync)
	local return_value = return_table.return_value

	if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter
		wml.variables[variable] = return_table.input
	elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc
		wml.variables[variable] = "null" -- any better choice?
	else wml.error( ( tostring( _"Prompt" ) .. ": " .. tostring( _"Error, return value :" ) .. tostring( return_value ) ) ) end -- any unhandled case is handled here
end

function wml_actions.choice_box( cfg )
	local variable = cfg.variable or wml.error( "Missing variable= key in [choice_box]" )
	local choice_values = {} -- it will be populated by preshow, and supply values to postshow
	local dialog_wml = wml.load "~add-ons/Wesnoth_Lua_Pack/gui/choice_box.cfg"
	local listbox_dialog = wml.get_child(dialog_wml, 'resolution')

	local function preshow(dialog)
		dialog.window_title.label = cfg.title
		dialog.window_message.label = cfg.message
		dialog.window_message.use_markup = true

		local counter = 1
		for option in wml.child_range( cfg, "option") do
			if option.value then
				choice_values[counter] = option.value
			else
				choice_values[counter] = counter -- just the same number, for simplicity sake
			end
			dialog.choices_listbox[counter].choice_image.label = option.image or ""
			dialog.choices_listbox[counter].choice_description.label = option.description or ""
			dialog.choices_listbox[counter].choice_description.use_markup = true
			dialog.choices_listbox[counter].choice_note.label = option.note or ""
			dialog.choices_listbox[counter].choice_note.use_markup = true
			counter = counter + 1
		end
	end
	local function sync()
		local choice_index
		local function postshow(dialog)
			choice_index = dialog.choices_listbox.selected_index
		end
		local return_value = gui.show_dialog( listbox_dialog, preshow, postshow )
		return { return_value = return_value, choice = choice_values[choice_index] } -- and retrieve the associated value
	end

	local return_table = wesnoth.sync.evaluate_single(sync)
	local return_value = return_table.return_value

	if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter
		wml.variables[variable] = return_table.choice
	elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc
		wml.variables[variable] = "null" -- any better choice?
	else wml.error( ( tostring( _"Choice box" ) .. ": " .. tostring( _"Error, return value :" ) .. tostring( return_value ) ) ) end -- any unhandled case is handled here
end
