local utils = {}

--! Function removes the first child with a given name.
--! melinath
function utils.remove_child(cfg, name)
	for index = 1, #cfg do
		local value = cfg[index]
		if value[1] == name then
			table.remove(cfg, index)
			return
		end
	end
end

--! Function checks recursively if all values contained in table a are also contained in table b.
--! melinath

function utils.filter_wml( f, t, indent )
	std_print( indent .. "Matching..." )
	local function sub_filter( f, t )
		local indent = indent .. "    "
		local attr_match = true
		local tables = 0

		for key, value in pairs(f) do
			if ( type(value) == "table" ) then
				tables = tables + 1
			else
				std_print( string.format( "%sChecking filter attribute: %s", indent, key ) )
				std_print( string.format( "%sfilter: %s", indent, tostring( f[key] ) ) )
				std_print( string.format( "%schecking: %s", indent, tostring( t[key] ) ) )

				if ( f[key] ~= t[key]) then attr_match = false end

				std_print( string.format( "%sMatch: %s", indent, tostring( f[key] == t[key] ) ) )
			end
		end

		if ( attr_match == false ) then return false
		else
			if ( tables==0 ) then return true end

			for key, value in pairs(f) do
				if ( type(value) == "table" ) then
					std_print( string.format( "%sEntering filter table: %s", indent, value[1] ) )

					for index = 1, #t do
						std_print( string.format( "%sChecking against: %s", indent, t[index][1] ) )
						std_print( string.format( "%sName Match: %s", indent, tostring( value[1] == t[index][1] ) ) )

						if( t[iindex][1] == value[1] ) then
							local x=sub_filter( value[2], t[index][2] )
							std_print( string.format( "%sTable match: %s", indent, tostring(x) ) )

							if x then return true end
						end
					end
				end
			end
			return false
		end
	end
	return sub_filter(f,t)
end

function utils.extract_side(side_num)
	local team = wesnoth.sides[side_num]
	local debug_utils = wesnoth.require("~add-ons/Wesnoth_Lua_Pack/debug_utils.lua")
	debug_utils.dbms(wesnoth.sides[side_num], false, string.format("Extraction of side %u", side_num, true))
end

function utils.extract_unit(filter)
	local char = wesnoth.get_units(filter)
	local debug_utils = wesnoth.require("~add-ons/Wesnoth_Lua_Pack/debug_utils.lua")
	debug_utils.dbms(char, false, string.format("Extraction of units (first character id: %s)", char[1].id), side_num, true)
end

--like wml_actions.message but without text wrap
function utils.message(cfg)
	local dialog =
		{
			{ "helptip", { id = "helptip_large" } },
			{ "tooltip", { id = "tooltip_large" } },
			{ "grid",
				{
					{ "row",
						{
							{ "column",
								{ horizontal_alignment = "left",
									{ "grid",
										{
											{ "row",
												{
													{ "column",
														{ border_size = 30, border = "all",
															{ "label",
																{ label = cfg.caption, definition = "title" }
															}
														}
													},
													{"column",
														{ border_size = 5, border = "all",
															{ "button",
																{ label = "abort", return_value = -2 }
															}
														}
													},
													{"column",
														{ border_size = 5, border = "all",
															{ "button",
																{ label = "continue", return_value = -1 }
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					},
					{ "row",
						{
							{ "column",
								{ border_size = 10, border = "all",
									{ "label", { label = cfg.message,
										use_markup = false }}
								}
							}
						}
					}
				}--grid
			}--grid
		}--dialog
	return wesnoth.sync.evaluate_single(function() local value = gui.show_dialog(dialog); return { key = value } end).key
end

--! Displays a WML text input message box with attributes from table @attr
--! with optional table @options containing optional label, max_length, and text key/value pairs.
--! @returns the entered text.
function utils.get_text_input(attr, options)
	options = options or {}
	local msg = {}
	for k,v in pairs(attr) do
		msg[k] = attr[k]
	end
	local ti = {}
	for k,v in pairs(options) do
		ti[k] = options[k]
	end
	ti["variable"]="LUA_text_input"
	table.insert(msg, { "text_input", ti })
	wesnoth.wml_actions.message(msg)
	local result = wml.variables["LUA_text_input"]
	wml.variables["LUA_text_input"] = nil
	return result
end

-- two support functions for handling strings
function utils.split( str, char )
	local char = char or ","
	local pattern = "[^" .. char .. "]+"
	return string.gmatch( str, pattern )
end

function utils.chop( str )
	local temp = string.gsub( str, "^%s+", "" )
	temp = string.gsub( temp, "%s+$", "" )
	return temp
end

return utils
