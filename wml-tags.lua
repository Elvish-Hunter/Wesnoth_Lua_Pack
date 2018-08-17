
local required_version = "1.13.12"
local sufficient = wesnoth.compare_versions and wesnoth.compare_versions(required_version, "<=", wesnoth.game_config.version)
if not sufficient then
	error(string.format("The Wesnoth Lua Pack requires Battle for Wesnoth %s or greater!", required_version))
end

local helper = wesnoth.require "lua/helper.lua"
local wlp_utils = wesnoth.require "~add-ons/Wesnoth_Lua_Pack/wlp_utils.lua"

-- to make code shorter. Yes, it's global.
wml_actions = wesnoth.wml_actions

-- support for translatable strings, custom textdomain
local _ = wesnoth.textdomain "wesnoth-Wesnoth_Lua_Pack"
-- #textdomain wesnoth-Wesnoth_Lua_Pack

--! [animate_path]
--! Alarantalara
-- move an image or set of images along any on screen path
-- see animation.lua for complete details
--? Should the interpolation methods table returned be added to the set of globals?
wesnoth.dofile '~add-ons/Wesnoth_Lua_Pack/animation.lua'

-- we need this file to use GUI-based stuff. Elvish_Hunter
wesnoth.dofile '~add-ons/Wesnoth_Lua_Pack/gui-tags.lua'

--! [store_shroud]
--! melinath

-- Given side= and variable=, stores that side's shroud data in that variable
-- Example:
-- [store_shroud]
--     side=1
--     variable=shroud_data
-- [/store_shroud]

function wml_actions.store_shroud(cfg)
	local side = wesnoth.get_sides( cfg )[1] or helper.wml_error("No matching side found in [store_shroud]")
	local variable = cfg.variable or helper.wml_error("Missing required variable= attribute in [store_shroud].")
	local current_shroud = side.__cfg.shroud_data
	wesnoth.set_variable(variable, current_shroud)
end

--! [set_shroud]
--! melinath

-- Given shroud data, removes the shroud in the marked places on the map.
-- Example:
-- [set_shroud]
--     side=1
--     shroud_data=$shroud_data # stored with store_shroud, for example!
-- [/set_shroud]

function wml_actions.set_shroud(cfg)
	local side = wesnoth.get_sides( cfg )[1] or helper.wml_error("No matching side found in [set_shroud]")
	local team_number = side.side
	local shroud_data = cfg.shroud_data or helper.wml_error("Missing required shroud_data= attribute in [set_shroud]")

	if shroud_data == nil then helper.wml_error("[set_shroud] was passed an empty shroud string")
	elseif string.sub(shroud_data,1,1) ~= "|" then helper.wml_error("[set_shroud] was passed an invalid shroud string")
	else
		-- yes, I prefer long variable names. I think that they make the code more understandable. E_H.
		local width, height, border = wesnoth.get_map_size()
		local shroud_x = ( 1 - border )

		-- my variation: to make code faster (hopefully), and avoid multiple callings of remove_shroud
		-- I append every location to a table, convert them as strings, and invoke remove_shroud
		-- only once, with these lists of locations. E_H.
		local rows, columns = {}, {}

		for row in string.gmatch ( shroud_data, "|(%d*)" ) do
			local shroud_y = ( 1 - border )
			for column in string.gmatch ( row, "%d" ) do
				if column == "1" then
					-- I tend to confuse them, so better specify: x are columns and y are rows. E_H.
					table.insert( rows, shroud_y ) -- appending them to the tables.
					table.insert( columns, shroud_x )
				end
				shroud_y = shroud_y + 1
			end
			shroud_x = shroud_x + 1
		end

		-- converting them to strings with separator
		local locs_x = table.concat( columns, "," )
		local locs_y = table.concat( rows, "," )

		if not wesnoth.sides[team_number].__cfg.shroud then
			wml_actions.modify_side { side = team_number, shroud = true } -- in case that shroud was removed by modify_side
		end

		wml_actions.place_shroud { side = team_number, x = string.format("%d-%d", 1 - border, height + border ), y = string.format("%d-%d", 1 - border, width + border ) }
		wml_actions.remove_shroud { side = team_number, x = locs_x, y = locs_y }
	end
end

--! [save_map],[load_map]
--! silene

--The [save_map] and [load_map] tags store and retrieve map data in a WML variable;
-- useful for dealing with dynamically modified yet persistent maps. They take a
-- variable=.
-- Example:
-- [save_map]
--     variable=saved_map[1].map
-- [/save_map]
-- [load_map]
--     variable=saved_map[1].map
-- [/load_map]

function wml_actions.save_map(cfg)
	local variable = cfg.variable or helper.wml_error "[save_map] missing required variable= attribute"
	local width, height, border = wesnoth.get_map_size()
	local t = {} -- not table, to avoid overriding the table library!

	for y = 1 - border, height + border do
		local row = {}

		for x = 1 - border, width + border do
			row[ x + border ] = wesnoth.get_terrain ( x, y )
		end

		t[ y + border ] = table.concat ( row, ',' )
	end

	local s = table.concat( t, '\n' ) -- not string, to avoid overriding the string library!
	wesnoth.set_variable ( variable, string.format ( "border_size=%d\nusage=map\n\n%s", border, s ) )
end

function wml_actions.load_map(cfg)
	local variable = cfg.variable or helper.wml_error "[load_map] missing required variable= attribute"
	wml_actions.replace_map { map = wesnoth.get_variable ( variable ), expand = true, shrink = true }
end

--! [narrate]
--! originally by silene, rewritten by Elvish_Hunter

-- shortcut for a [message] tag spoken by the narrator.

function wml_actions.narrate(cfg)
	local cfg = cfg.__literal
	cfg.speaker = "narrator"
	if not cfg.image then cfg.image = "wesnoth-icon.png" end
	wml_actions.message( cfg )
end

local function flash(red,green,blue)
	-- usage: call this function by specifying the maximum values for each color. Don't go above 100.
	wml_actions.color_adjust { red = (red * 0.67), green = (green * 0.67), blue = (blue * 0.67) }
	wml_actions.color_adjust { red = red, green = green, blue = blue }
	wml_actions.color_adjust { red = (red * 0.33), green = (green * 0.33), blue = (blue * 0.33) }
	wml_actions.color_adjust { red = 0, green = 0, blue = 0 }
end

function wml_actions.flash_color(cfg)
	local red = tonumber(cfg.red) or helper.wml_error("[flash_color] is missing required red= attribute")
	local green = tonumber(cfg.green) or helper.wml_error("[flash_color] is missing required green= attribute")
	local blue = tonumber(cfg.blue) or helper.wml_error("[flash_color] is missing required blue= attribute")

	flash( red, green, blue )
end

function wml_actions.flash_screen(cfg)
	local color = cfg.color or helper.wml_error("[flash_screen] is missing required color= attribute")
	if color == "white" then
		flash( 100, 100, 100 )
	elseif color == "red" then
		flash( 100, 0, 0 )
	elseif color == "green" then
		flash( 0, 100, 0 )
	elseif color == "blue" then
		flash( 0, 0, 100 )
	elseif color == "magenta" or color == "fuchsia" then
		flash( 100, 0, 100 )
	elseif color == "yellow" then
		flash( 100, 100, 0 )
	elseif color == "cyan" or color == "aqua" then
		flash( 0, 100, 100 )
	elseif color == "purple" then
		flash( 50, 0, 50 )
	elseif color == "orange" then
		flash( 100, 65, 0 )
	elseif color == "black" then
		flash( -100, -100, -100 )
	else
		helper.wml_error("Unsupported color in [flash_screen]")
	end
end

function wml_actions.nearest_hex(cfg)
	local starting_x = tonumber(cfg.starting_x) or helper.wml_error("Missing required starting_x in [nearest_hex]")
	local starting_y = tonumber(cfg.starting_y) or helper.wml_error("Missing required starting_y in [nearest_hex]")
	local filter = (helper.get_child(cfg, "filter_location")) or helper.wml_error("Missing required [filter_location] in [nearest_hex]")
	local variable = cfg.variable or "nearest_hex" -- default

	local current_distance = math.huge -- feed it the biggest value possible
	local nearest_hex_found

	for index,location in ipairs(wesnoth.get_locations(filter)) do
		local distance = helper.distance_between( starting_x, starting_y, location[1], location[2] )
		if distance < current_distance then
			current_distance = distance
			nearest_hex_found = location
		end
	end

	if nearest_hex_found then
		wesnoth.set_variable( variable, { x = nearest_hex_found[1], y = nearest_hex_found[2], terrain = wesnoth.get_terrain( nearest_hex_found[1], nearest_hex_found[2] ) })
	else wesnoth.message( "WML", "No suitable location found by [nearest_hex]" )
	end
end

function wml_actions.nearest_unit(cfg)
	local starting_x = tonumber(cfg.starting_x) or helper.wml_error("Missing required starting_x in [nearest_unit]")
	local starting_y = tonumber(cfg.starting_y) or helper.wml_error("Missing required starting_y in [nearest_unit]")
	local filter = (helper.get_child(cfg, "filter")) or helper.wml_error("Missing required [filter] in [nearest_unit]")
	local variable = cfg.variable or "nearest_unit" -- default

	local current_distance = math.huge -- feed it the biggest value possible
	local nearest_unit_found

	for index,unit in ipairs(wesnoth.get_units(filter)) do
		local distance = helper.distance_between( starting_x, starting_y, unit.x, unit.y )
		if distance < current_distance then
			current_distance = distance
			nearest_unit_found = unit
		end
	end

	if nearest_unit_found then
		wml_actions.store_unit( { variable = variable, { "filter", { id = nearest_unit_found.id } } } )
	else wesnoth.message( "WML", "No suitable unit found by [nearest_unit]" )
	end
end

-- to store unit defense
function wesnoth.wml_actions.get_unit_defense(cfg)
	local filter = wesnoth.get_units(cfg)
	local variable = cfg.variable or "defense"

	for index, unit in ipairs(filter) do
		local terrain = wesnoth.get_terrain ( unit.x, unit.y )
		-- it is WML defense: the lower, the better. Converted to normal defense with 100 -
		local defense = 100 - wesnoth.unit_defense ( unit, terrain )
		wesnoth.set_variable ( string.format ( "%s[%d]", variable, index - 1 ), { id = unit.id, x = unit.x, y = unit.y, terrain = terrain, defense = defense } )
	end
end

local _ = wesnoth.textdomain "wesnoth"
-- #textdomain wesnoth

function wml_actions.slow(cfg)
	for index, unit in ipairs(wesnoth.get_units(cfg)) do
		if unit.valid and not unit.status.slowed then
			unit.status.slowed = true
			if unit.__cfg.gender == "female" then
				wesnoth.float_label( unit.x, unit.y, string.format("<span color='red'>%s</span>", tostring( _"female^slowed" ) ) )
			else
				wesnoth.float_label( unit.x, unit.y, string.format("<span color='red'>%s</span>", tostring( _"slowed" ) ) )
			end
		end
	end
end

function wml_actions.poison(cfg)
	for index, unit in ipairs(wesnoth.get_units(cfg)) do
		if unit.valid and not unit.status.poisoned and not unit.status.not_living then
			unit.status.poisoned = true
			if unit.__cfg.gender == "female" then
				wesnoth.float_label(unit.x, unit.y, string.format("<span color='red'>%s</span>", tostring( _"female^poisoned" ) ) )
			else
				wesnoth.float_label(unit.x, unit.y, string.format("<span color='red'>%s</span>", tostring( _"poisoned" ) ) )
			end
		end
	end
end

function wml_actions.unpoison(cfg) -- removes poison from all units matching the filter.
	for index, unit in ipairs(wesnoth.get_units(cfg)) do
		if unit.valid then unit.status.poisoned = nil end
	end
end

function wml_actions.unslow(cfg) -- removes slow from all units matching the filter.
	for index, unit in ipairs(wesnoth.get_units(cfg)) do
		if unit.valid then unit.status.slowed = nil end
	end
end

local function fade( value, delay ) -- equivalent to FADE_STEP WML macro
	wml_actions.color_adjust { red = value, green = value, blue = value }
	wesnoth.delay( delay )
	wml_actions.redraw {}
end

function wml_actions.fade_to_black(cfg) -- replaces FADE_TO_BLACK macro
	local interval = tonumber( cfg.interval or 5 )

	for value = -32, -224, -32 do
		fade( value, interval )
	end
end

function wml_actions.fade_to_black_hold(cfg) -- replaces FADE_TO_BLACK_HOLD macro
	local delay = tonumber( cfg.delay ) or helper.wml_error( "Missing delay= in [fade_to_black_hold]" )
	local interval = tonumber( cfg.interval or 5 )

	for value = -32, -192, -32 do
		fade( value, interval )
	end

	fade( -224, delay )
end

function wml_actions.fade_in(cfg) -- replaces FADE_IN macro
	local interval = tonumber( cfg.interval or 5 )

	for value = -224, 0, 32 do
		fade( value, interval )
	end
end

function wml_actions.fade_to_white(cfg) -- similar to a theoretical FADE_TO_WHITE macro
	local interval = tonumber( cfg.interval or 5 )
	for value = 32, 224, 32 do
		fade( value, interval )
	end
end

function wml_actions.fade_to_white_hold(cfg) -- like a FADE_TO_WHITE_HOLD macro
	local delay = tonumber( cfg.delay ) or helper.wml_error( "Missing delay= in [fade_to_black_hold]" )
	local interval = tonumber( cfg.interval or 5 )

	for value = 32, 192, 32 do
		fade( value, interval )
	end

	fade( 224, delay )
end

function wml_actions.fade_in_from_white(cfg) -- use after [fade_to_white] or [fade_to_white_hold]
	local interval = tonumber( cfg.interval or 5 )

	for value = 224, 0, -32 do
		fade( value, interval )
	end
end

function wml_actions.scatter_units(cfg) -- replacement for SCATTER_UNITS macro
	local locations = wesnoth.get_locations( helper.get_child( cfg, "filter_location" ) ) or helper.wml_error( "Missing required [filter_location] in [scatter_units]" )
	local unit_string = cfg.unit_types or helper.wml_error( "Missing required unit_types= in [scatter_units]" )
	local units = tonumber( cfg.units ) or helper.wml_error( "Missing or wrong required units= in [scatter_units]" )
	local scatter_radius =  tonumber( cfg.scatter_radius ) -- not mandatory, if nil cycle will be jumped
	local unit_table = helper.parsed( helper.get_child( cfg, "wml" ) ) or {} -- initialize as empty table, just in need

	local unit_types = {} -- create a table, then append each value after splitting with string.gmatch.

	for value in string.gmatch( unit_string, "[^%s,][^,]*" ) do
		table.insert( unit_types, value )
	end

	if #locations <=0 then return -- if no locations, end
	else
		repeat -- repeat cycle is executed at least once
			local rand_locs = "1.." .. #locations -- concatenation for use by WML rand
			local rand_units = "1.." .. #unit_types
			local index = helper.rand( rand_locs ) -- use helper.rand, to avoid OOS errors
			local index2 = helper.rand( rand_units )
			local where_to_place = locations[index]

			local unit_to_put = unit_table
			unit_to_put.type = unit_types[index2]

			local free_x, free_y = wesnoth.find_vacant_tile( where_to_place[1], where_to_place[2], unit_to_put)
			-- to avoid placing units in strange terrains, or overwriting, in case that the WML coder placed a wrong filter;
			-- in such case, respect of scatter_radius is not guaranteed, exactly like in SCATTER_UNITS

			unit_to_put.x, unit_to_put.y = free_x, free_y
			wesnoth.put_unit( unit_to_put )
			table.remove( locations, index ) -- to remove such location from the available list, because it's already busy, and avoid overwriting already placed units
			if scatter_radius then -- loop for scatter_radius; will remove every location within the radius
				-- apparently, a reversed ipairs like below is the best way to check every location
				-- and remove those that are too close
				-- using standard ipairs jumps some locations
				for index = #locations, 1, -1 do --lenght of locations, until 1, step -1
					local distance = helper.distance_between( where_to_place[1], where_to_place[2], locations[index][1], locations[index][2] )

					if distance < scatter_radius then
						table.remove( locations, index )
					end
				end
			end

			units = units - 1 -- counter variable
		until units <= 0 or #locations <= 0
	end
end

-- math functions by Espreon
--[[ examples of usage:
[set_variable]
	name=test_math_1
	value=-12
[/set_variable]
[absolute_value]
	variable=test_math_1
	result_variable=test_math_1_abs
[absolute_value]
	variable=test_math_1
[/absolute_value]
[get_numerical_minimum]
	first_value=12
	other_value=24
	result_variable=test_math_2
[/get_numerical_minimum]
[get_numerical_maximum]
	first_value=12
	other_value=24
	result_variable=test_math_3
[/get_numerical_maximum]
[get_percentage]
	value=750
	percentage=2.5
	variable=test_math_4
[/get_percentage]
[get_ratio_as_percentage]
	numerator=22
	denominator=7
	variable=test_math_5
[/get_ratio_as_percentage] ]]
function wml_actions.absolute_value(cfg)
	local variable = cfg.variable or
		helper.wml_error "[absolute_value] missing required variable= attribute"

	local variable_value = wesnoth.get_variable(variable)
	local result = math.abs(variable_value)

	if cfg.result_variable == nil then
		wesnoth.set_variable(variable, result)
	else
		wesnoth.set_variable(cfg.result_variable, result)
	end
end

function wml_actions.get_numerical_minimum(cfg)
	-- notify users of the change
	if cfg.first_value then	helper.wml_error "first_value= attribute is no longer supported in [get_numerical_minimum], use values= instead" end
	if cfg.other_value then	helper.wml_error "other_value= attribute is no longer supported in [get_numerical_minimum], use values= instead" end
	-- values is a comma separated list
	local values = cfg.values or helper.wml_error "[get_numerical_minimum] missing required value= attribute"
	local result_variable = cfg.result_variable or helper.wml_error "[get_numerical_minimum] missing required result_variable= attribute"
	
	-- set an empty table
	local args = { }
	-- take the string before and split it on commas
	for arg in wlp_utils.split( values ) do
		-- convert all values to numbers. Strings, booleans, etc. will become nil, and spaces will be removed
		table.insert( args, tonumber( arg ) )
	end

	-- what's the lowest value? Convert the args table to a series of arguments and feed them to math.min
	wesnoth.set_variable( result_variable, math.min( table.unpack( args ) ) )
end

function wml_actions.get_numerical_maximum(cfg)
	-- notify users of the change
	if cfg.first_value then	helper.wml_error "first_value= attribute is no longer supported in [get_numerical_maximum], use values= instead" end
	if cfg.other_value then	helper.wml_error "other_value= attribute is no longer supported in [get_numerical_maximum], use values= instead" end
	-- values is a comma separated list
	local values = cfg.values or helper.wml_error "[get_numerical_maximum] missing required value= attribute"
	local result_variable = cfg.result_variable or helper.wml_error "[get_numerical_maximum] missing required result_variable= attribute"
	
	-- set an empty table
	local args = { }
	-- take the string before and split it on commas
	for arg in wlp_utils.split( values ) do
		-- convert all values to numbers. Strings, booleans, etc. will become nil, and trailing spaces will be removed
		table.insert( args, tonumber( arg ) )
	end

	-- what's the highest value? Convert the args table to a series of arguments and feed them to math.max
	wesnoth.set_variable( result_variable, math.max( table.unpack( args ) ) )
end

function wml_actions.get_percentage(cfg)
	local value = cfg.value or
		helper.wml_error "[get_percentage] missing required value= attribute"
	local percentage = cfg.percentage or
		helper.wml_error "[get_percentage] missing required percentage= attribute"
	local variable = cfg.variable or
		helper.wml_error "[get_percentage] missing required variable= attribute"

	local result = (value * percentage) / 100
	wesnoth.set_variable(variable, result)
end

function wml_actions.get_ratio_as_percentage(cfg)
	local numerator = cfg.numerator or
		helper.wml_error "[get_ratio_as_percentage] missing required numerator= attribute"
	local denominator = cfg.denominator or
		helper.wml_error "[get_ratio_as_percentage] missing required denominator= attribute"
	local variable = cfg.variable or
		helper.wml_error "[get_ratio_as_percentage] missing required variable= attribute"

	local result = (100 * numerator) / denominator
	wesnoth.set_variable(variable, result)
end

-- [unknown_message], by Espreon, with modifications by Elvish_Hunter
--[[ usage:
[unknown_message]
	message=_"Hi"
	color=2
	caption = _ "WesnothAI"
	right = yes/no
[/unknown_message] ]]
function wml_actions.unknown_message(cfg)
	local message = cfg.message or
		helper.wml_error "[unknown_message] missing required message= attribute"
	local image

	if type(cfg.color) == "string" then
		image = string.format("units/unknown-unit.png~RC(magenta>%s)", cfg.color)
	elseif type(cfg.color) == "number" then
		image = string.format("units/unknown-unit.png~TC(%d,magenta)", cfg.color)
	else -- if cfg.color is nil, table, or whatever else
		image = "units/unknown-unit.png"
	end

	if cfg.right then
		image = image .. "~RIGHT()"
	end

	wesnoth.message { speaker = "narrator", message = cfg.message, caption = cfg.caption, image = image, duration = cfg.duration, side_for = cfg.side_for, sound = cfg.sound }
end

-- [get_movement_type], by silene
--[[ Usage:
[get_movement_type]
# a Standard Unit Filter
x,y=$x1,$y1
# a variable name or "movement_type" if missing
variable=variable_name
[/get_movement_type]
Stores the unit's movement type in the given variable. ]]
function wml_actions.get_movement_type(cfg)
	local unit = wesnoth.get_units(cfg)[1] or helper.wml_error "[get_movement_type] filter didn't match any unit"
	local unit_type = wesnoth.unit_types[unit.type]
	local variable = cfg.variable or "movement_type"
	wesnoth.set_variable( variable, unit_type.__cfg.movement_type )
end

-- [reverse_value]: reverses the content of a variable. Usage:
--	[reverse_value]
--		variable=test
--		result_variable=test2
--	[/reverse_value]
function wml_actions.reverse_value( cfg )
	local variable = cfg.variable or helper.wml_error( "[reverse_value] missing required variable= attribute" )
	local result_variable = cfg.result_variable or cfg.variable -- if there is a result_variable= the original variable won't be overwritten
	local temp_value = wesnoth.get_variable( variable )
	local type_value = type( temp_value )
	if type_value == "string" or type_value == "number" then
		wesnoth.set_variable( result_variable, string.reverse( temp_value ) )
	elseif type_value == "userdata" then -- handle translatable strings, or at least try to
		wesnoth.set_variable( result_variable, string.reverse( tostring ( temp_value ) ) )
	else helper.wml_error( "Invalid value in [reverse_value] tag" )
	end
end

-- [whisper]: a replacement for both WHISPER and ASIDE macros
--	[whisper]
--		message=_"Message"
--		caption=_"A unit"
--		sound=gold.ogg
--	[/whisper]
function wml_actions.whisper( cfg )
	local message = string.format ( "<small><i>%s</i></small>", tostring( cfg.message ) )
	wml_actions.message { speaker = cfg.speaker or "narrator",
				image = cfg.image or "wesnoth-icon.png",
				caption = cfg.caption,
				message = message,
				duration = cfg.duration,
				side_for = cfg.side_for,
				sound = cfg.sound }
end

--[[function wml_actions.random_seed( cfg )
	local seed = tonumber( cfg.seed ) or helper.wml_error( "Missing or wrong seed= attribute in [random_seed]" )
	math.randomseed( seed )
end]]

function wml_actions.random_number( cfg )
	local lowest = tonumber( cfg.lowest ) or helper.wml_error( "Missing or wrong lowest= attribute in [random_number]" )
	local highest = tonumber( cfg.highest ) or helper.wml_error( "Missing or wrong highest= attribute in [random_number]" )
	local variable = cfg.variable or "random"

	-- does not work in start event
	local result = wesnoth.synchronize_choice( function()
    		return { value = math.random( lowest, highest ) }
	end)

	wesnoth.set_variable( variable, result.value )
end

function wml_actions.get_recruit_list( cfg )
	-- support function
	-- Lua does not have the in operator as Python
	-- in Python, "in" can be used also to check if a list contains a certain value, not only to iterate
	local function check( t, v )
		for i, va in ipairs( t ) do
			if type( v ) == type( va ) and v == va then
				return true
			end
		end
		return false
	end

	local filter_side = helper.get_child( cfg, "filter_side" ) or helper.wml_error( "Missing [filter_side] in [get_recruit_list]" )
	local filter = helper.get_child( cfg, "filter" )
	local variable = cfg.variable or "recruit_list"

	for index, side in ipairs( wesnoth.get_sides( filter_side ) ) do
		local recruit_list = { }

		for recruitable in string.gmatch( side.__cfg.recruit, '[^,]+' ) do
			table.insert( recruit_list, recruitable )
		end

		if filter then
			filter.side = side.side -- to avoid collecting extra_recruit from enemies
			for index,unit in ipairs( wesnoth.get_units( filter ) ) do
				if unit.canrecruit and #unit.extra_recruit > 0 then
					for extra_index, extra_recruitable in ipairs( unit.extra_recruit ) do
						if not check( recruit_list, extra_recruitable ) then
							table.insert( recruit_list, extra_recruitable )
						end
					end
				end
			end
		end

		wesnoth.set_variable( string.format( "%s[%d]", variable, index - 1 ), { side = side.side,
											team_name = side.team_name,
											user_team_name = side.user_team_name,
											name = side.name,
											recruit_list = table.concat( recruit_list, "," ) } )
	end
end

function wml_actions.earthquake( cfg )
	local counter = cfg.times or 1
	local delay = cfg.delay or 50
	local coordinates = { {5,0},{-10,0},{-5,5},{0,-10},{0,5} }
	repeat
		wesnoth.play_sound( "rumble.ogg" )
		for i, v in ipairs( coordinates ) do
			wesnoth.scroll( v[1], v[2] )
			wesnoth.delay( delay )
		end
		counter = counter - 1
	until counter <= 0
end

-- [loot]: replacement for mainline LOOT macro
-- supported parameters:
-- StandardSideFilter
-- amount, raises error if not number
function wml_actions.loot( cfg )
	local gold_amount = tonumber( cfg.amount ) or helper.wml_error( "Missing or wrong amount= value in [loot]" )
	local sides = wesnoth.get_sides( cfg )
	for index, side in ipairs( sides ) do
		wml_actions.message {
			side_for = side.side,
			speaker = "narrator",
			message = string.format( tostring( _"You retrieve %d pieces of gold." ), gold_amount ),
			image = "wesnoth-icon.png",
			sound = "gold.ogg"
		}
		side.gold = side.gold + gold_amount
	end
end
