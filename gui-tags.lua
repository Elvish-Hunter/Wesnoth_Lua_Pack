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
	-- acquire unit with get_units, if unit.valid show dialog
	local lua_dialog_unit = wesnoth.get_units ( { x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1 } )[1] -- clearly, at x1,y1 there could be only one unit
	local oversize_factor = 10 -- make it possible to increase over unit.max_attacks; no idea what would be a sensible value
	if lua_dialog_unit and lua_dialog_unit.valid then -- to avoid indexing a nil value
		--creating dialog here
		-- read only labels
		local read_only_panel = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"ID"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "unit_id" --unit.id
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Valid"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "unit_valid" --unit.valid
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Type"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "unit_type" --unit.type
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Can recruit"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "unit_canrecruit"--unit.canrecruit
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Race"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "unit_race" -- unit.race
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Cost"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "unit_cost" -- unit.cost
								}
							}
						}
					}

		local location_form = T.grid {
			T.row {
				grow_factor = 0,
				T.column {
					horizontal_alignment = "left",
					border = "all",
					border_size = 5,
					T.label {
						label = _"X"
					}
				},
				T.column {
					vertical_grow = true,
					horizontal_grow = true,
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.text_box {
						id = "textbox_loc_x", -- unit.x
						history = "other_loc_x",
					}
				},
				T.column {
					horizontal_alignment = "left",
					border = "all",
					border_size = 5,
					T.label {
						label = _"Y"
					}
				},
				T.column {
					vertical_grow = true,
					horizontal_grow = true,
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.text_box {
						id = "textbox_loc_y", -- unit.y
						history = "other_loc_y",
					}
				}
			}
		}

		local upkeep_form = T.grid {
			T.row {
				T.column {
					grow_factor = 0,
					T.horizontal_listbox {
						id = "upkeep_listbox",
						T.list_definition {
							T.row {
								T.column {
									horizontal_alignment = "left",
									border = "left,right",
									border_size = 5,
									T.toggle_button {
										id = "upkeep_radiobutton",
										definition = "radio"
									}
								}
							}
						},
						T.list_data {
							T.row {
								T.column {
									label = _"Loyal"
								}
							},
							T.row {
								T.column {
									label = _"Full"
								}
							},
							T.row {
								T.column {
									label = _"Other"
								}
							}
						}
					}
				},
				T.column {
					horizontal_grow = true,
					vertical_grow = true,
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.slider {
						minimum_value = 0,
						maximum_value = 5,
						step_size = 1,
						id = "upkeep_slider"
					}
				}
			}
		}

		local status_checkbuttons = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Poisoned",
									id = "poisoned_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Slowed",
									id = "slowed_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Petrified",
									id = "petrified_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Invulnerable",
									id = "invulnerable_checkbutton"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Uncovered",
									id = "uncovered_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Guardian",
									id = "guardian_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Unhealable",
									id = "unhealable_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Stunned",
									id = "stunned_checkbutton"
								}
							}
						}
					}

		local alignment_radiobutton = T.horizontal_listbox {
							id = "alignment_listbox",
							T.list_definition {
								T.row {
									T.column {
										horizontal_alignment = "left",
										border = "all",
										border_size = 5,
										T.toggle_button {
											id = "alignment_radiobutton",
											definition = "radio"
										}
									}
								}
							},
							T.list_data {
								T.row {
									T.column {
										label = _"Lawful"
									}
								},
								T.row {
									T.column {
										label = _"Neutral"
									}
								},
								T.row {
									T.column {
										label = _"Chaotic"
									}
								},
								T.row {
									T.column {
										label = _"Liminal"
									}
								}
							}
						}

		local facing_radiobutton = T.horizontal_listbox {
						id = "facing_listbox",
						T.list_definition {
							T.row {
								T.column {
									horizontal_alignment = "left",
									border = "all",
									border_size = 5,
									T.toggle_button {
										id = "facing_radiobutton",
										definition = "radio"
									}
								}
							}
						},
						T.list_data {
							T.row {
								T.column {
									label = _"nw"
								}
							},
							T.row {
								T.column {
									label = _"ne"
								}
							},
							T.row {
								T.column {
									label = _"n"
								}
							},
							T.row {
								T.column {
									label = _"sw"
								}
							},
							T.row {
								T.column {
									label = _"se"
								}
							},
							T.row {
								T.column {
									label = _"s"
								}
							}
						}
					}


		local misc_checkbuttons = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Resting",
									id = "resting_checkbutton" --unit.resting
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _"Hidden",
									id = "hidden_checkbutton" --unit.hidden
								}
							}
						}
					}

		-- buttonbox
		local buttonbox = T.grid {
					T.row {
						T.column {
							T.button {
								label = "✔ " .. _"OK",
								return_value = 1
							}
						},
						T.column {
							T.spacer {
								width = 10
							}
						},
						T.column {
							T.button {
								label = "✘ " .. _"Cancel",
								return_value = 2
							}
						}
					}
				}

		-- widgets for modifying unit
		local modify_panel = T.grid {
					-- location form
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Location"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							grow_factor = 1,
							border = "all",
							border_size = 5,
							location_form
						}
					},
					-- level slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Level"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, lua_dialog_unit.level ),
								maximum_value = math.max( 5, lua_dialog_unit.level ),
								step_size = 1,
								id = "unit_level_slider" --unit.level
							}
						}
					},
					-- side slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Side"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 1,
								maximum_value = math.max( 2, #wesnoth.sides ), -- to avoid crash if there is only one side
								step_size = 1,
								id = "unit_side_slider" --unit.side
							}
						}
					},
					-- hitpoints slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Hitpoints"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min(0, lua_dialog_unit.hitpoints),
								maximum_value = math.max(lua_dialog_unit.max_hitpoints * oversize_factor, lua_dialog_unit.hitpoints),
								minimum_value_label = _"Kill unit",
								--maximum_value_label = _"Full health",
								step_size = 1,
								id = "unit_hitpoints_slider" --unit.hitpoints
							}
						}
					},
					-- experience slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Experience"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min(0, lua_dialog_unit.experience),
								maximum_value = math.max(lua_dialog_unit.max_experience * oversize_factor, lua_dialog_unit.experience),
								--maximum_value_label = _"Level up",
								step_size = 1,
								id = "unit_experience_slider" --unit.experience
							}
						}
					},
					-- moves slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Moves"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								-- to avoid crashing if max_moves == 0
								maximum_value = math.max(1, lua_dialog_unit.max_moves * oversize_factor, lua_dialog_unit.moves),
								step_size = 1,
								id = "unit_moves_slider" --unit.moves
							}
						}
					},
					-- attacks slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Attacks left"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								-- to avoid crashing if unit has max_attacks == 0
								maximum_value = math.max(1, lua_dialog_unit.max_attacks * oversize_factor, lua_dialog_unit.attacks_left),
								step_size = 1,
								id = "unit_attacks_slider" --unit.attacks_left
							}
						}
					},
					-- upkeep
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Upkeep"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							upkeep_form
						}
					},
					-- name
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Name"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_name", -- unit.name
								history = "other_names"
							}
						}
					},
					-- extra recruit
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Extra recruit"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_extra_recruit", --unit.extra_recruit
								history = "other_recruits"
							}
						}
					},
					-- advances to
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Advances to"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_advances_to", --unit.advances_to
								history = "other_advancements"
							}
						}
					},
					-- role
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Role"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_role", --unit.role
								history = "other_roles"
							}
						}
					},
					-- statuses
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Status"
							}
						},
						T.column {
							horizontal_alignment = "left",
							status_checkbuttons
						}
					},
					-- alignment
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Alignment"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							alignment_radiobutton
						}
					},
					-- facing
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Facing"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							facing_radiobutton
						}
					},
					-- misc
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Misc"
							}
						},
						T.column {
							horizontal_alignment = "left",
							misc_checkbuttons
						}
					}
				}

		local debug_dialog = {
			T.helptip { id="tooltip_large" }, -- mandatory field
			T.tooltip { id="tooltip_large" }, -- mandatory field
			maximum_height = 600,
			maximum_width = 800,
			T.grid { -- Title
				T.row {
					T.column { 
						horizontal_alignment = "left",
						grow_factor = 1,
						border = "all",
						border_size = 5,
						T.label {
							definition = "title",
							label = _"Quick Debug Menu"
						}
					}
				},
				-- Subtitile
				T.row {
					T.column {
						horizontal_alignment = "left",
						border = "all",
						border_size = 5,
						T.label {
							label = _"Set the desired parameters, then press OK to confirm or Cancel to exit"
						}
					}
				},
				-- non-modifiable proxies, melinath's layout
				T.row {
					T.column {
						T.grid {
							T.row {
								T.column {
									vertical_alignment = "top",
									T.grid {
										T.row {
											T.column {
												vertical_alignment = "center",
												horizontal_alignment = "center",
												border = "all",
												border_size = 5,
												T.image {
													id = "unit_image" -- unit sprite
												}
											}
										},
										T.row {
											T.column {
												read_only_panel
											}
										}
									}
								},
								-- modification part
								T.column {
									T.scrollbar_panel {
										T.definition {
											T.row {
												T.column {
													modify_panel
												}
											}
										}
									}
								}
							}
						}
					}
				},
				-- button box
				T.row {
					T.column {
						border = "all",
						border_size = 5,
						buttonbox
					}
				}
			}
		}

		local temp_table = { } -- to store values before checking if user allowed modifying

		local function preshow()
			-- here set all widget starting values
			-- set read_only labels
			wesnoth.set_dialog_value ( lua_dialog_unit.id, "unit_id" )
			wesnoth.set_dialog_value ( lua_dialog_unit.valid, "unit_valid" )
			wesnoth.set_dialog_value ( lua_dialog_unit.type, "unit_type" )
			wesnoth.set_dialog_value ( lua_dialog_unit.canrecruit, "unit_canrecruit" )
			wesnoth.set_dialog_value ( lua_dialog_unit.race, "unit_race" )
			wesnoth.set_dialog_value ( lua_dialog_unit.cost, "unit_cost" )
			wesnoth.set_dialog_value ( string.format("%s~TC(%d,magenta)", lua_dialog_unit.__cfg.image or "", lua_dialog_unit.side), "unit_image" )
			-- set location form
			wesnoth.set_dialog_value ( lua_dialog_unit.x, "textbox_loc_x" )
			wesnoth.set_dialog_value ( lua_dialog_unit.y, "textbox_loc_y" )
			-- set sliders
			wesnoth.set_dialog_value ( lua_dialog_unit.level, "unit_level_slider" )
			wesnoth.set_dialog_value ( lua_dialog_unit.side, "unit_side_slider" )
			wesnoth.set_dialog_value ( lua_dialog_unit.hitpoints, "unit_hitpoints_slider" )
			wesnoth.set_dialog_value ( lua_dialog_unit.experience, "unit_experience_slider" )
			wesnoth.set_dialog_value ( lua_dialog_unit.moves, "unit_moves_slider" )
			wesnoth.set_dialog_value ( lua_dialog_unit.attacks_left, "unit_attacks_slider" )
			-- set upkeep
			local upkeep = lua_dialog_unit.upkeep
			if upkeep == "loyal" or upkeep == "free" then
				wesnoth.set_dialog_value ( 1, "upkeep_listbox" )
				wesnoth.set_dialog_active ( false, "upkeep_slider" )
			elseif upkeep == "full" then
				wesnoth.set_dialog_value ( 2, "upkeep_listbox" )
				wesnoth.set_dialog_active ( false, "upkeep_slider" )
			else
				wesnoth.set_dialog_value ( 3, "upkeep_listbox" )
				wesnoth.set_dialog_value ( tonumber(upkeep), "upkeep_slider" )
			end

			-- the slider becomes active only if the upkeep becomes a numerical value
			local function upkeep_cb()
				if wesnoth.get_dialog_value ( "upkeep_listbox" ) == 3 then
					wesnoth.set_dialog_active ( true, "upkeep_slider" )
				else
					wesnoth.set_dialog_active ( false, "upkeep_slider" )
				end
			end
			wesnoth.set_dialog_callback( upkeep_cb, "upkeep_listbox" )

			-- set textboxes
			wesnoth.set_dialog_value ( lua_dialog_unit.name, "textbox_name" )
			wesnoth.set_dialog_value ( table.concat( lua_dialog_unit.extra_recruit, "," ), "textbox_extra_recruit" )
			wesnoth.set_dialog_value ( table.concat( lua_dialog_unit.advances_to, "," ), "textbox_advances_to" )
			wesnoth.set_dialog_value ( lua_dialog_unit.role, "textbox_role" )
			-- set checkbuttons
			wesnoth.set_dialog_value ( lua_dialog_unit.status.poisoned, "poisoned_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.slowed, "slowed_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.petrified, "petrified_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.invulnerable, "invulnerable_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.uncovered, "uncovered_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.guardian, "guardian_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.unhealable, "unhealable_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.status.stunned, "stunned_checkbutton" )
			-- set radiobutton for alignment
			local temp_alignment
			if lua_dialog_unit.alignment == "lawful" then temp_alignment = 1
			elseif lua_dialog_unit.alignment == "neutral" then temp_alignment = 2
			elseif lua_dialog_unit.alignment == "chaotic" then temp_alignment = 3
			elseif lua_dialog_unit.alignment == "liminal" then temp_alignment = 4
			end
			wesnoth.set_dialog_value ( temp_alignment, "alignment_listbox" )
			-- set radiobutton for facing
			local temp_facing
			if lua_dialog_unit.facing == "nw" then temp_facing = 1
			elseif lua_dialog_unit.facing == "ne" then temp_facing = 2
			elseif lua_dialog_unit.facing == "n" then temp_facing = 3
			elseif lua_dialog_unit.facing == "sw" then temp_facing = 4
			elseif lua_dialog_unit.facing == "se" then temp_facing = 5
			elseif lua_dialog_unit.facing == "s" then temp_facing = 6
			end
			wesnoth.set_dialog_value ( temp_facing, "facing_listbox" )
			-- other checkbuttons
			wesnoth.set_dialog_value ( lua_dialog_unit.resting, "resting_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_unit.hidden, "hidden_checkbutton" )
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow()
				-- here get all the widget values in variables; store them in temp variables
				-- location form; it requires a validation procedure
				local new_x, new_y
				new_x = tonumber(wesnoth.get_dialog_value( "textbox_loc_x" ))
				new_y = tonumber(wesnoth.get_dialog_value( "textbox_loc_y" ))
				local width, height, border = wesnoth.get_map_size()

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
				local upkeep_type = wesnoth.get_dialog_value ( "upkeep_listbox" )
				if upkeep_type == 1 then
					temp_table.upkeep = "loyal"
				elseif upkeep_type == 2 then
					temp_table.upkeep = "full"
				elseif upkeep_type == 3 then
					temp_table.upkeep = wesnoth.get_dialog_value( "upkeep_slider" )
				end

				-- sliders
				temp_table.level = wesnoth.get_dialog_value( "unit_level_slider" )
				temp_table.side = wesnoth.get_dialog_value ( "unit_side_slider" )
				temp_table.hitpoints = wesnoth.get_dialog_value ( "unit_hitpoints_slider" )
				temp_table.experience = wesnoth.get_dialog_value ( "unit_experience_slider" )
				temp_table.moves = wesnoth.get_dialog_value ( "unit_moves_slider" )
				temp_table.attacks_left = wesnoth.get_dialog_value ( "unit_attacks_slider" )
				-- text boxes
				temp_table.name = wesnoth.get_dialog_value "textbox_name"
				temp_table.advances_to = wesnoth.get_dialog_value "textbox_advances_to"
				temp_table.extra_recruit = wesnoth.get_dialog_value "textbox_extra_recruit"
				temp_table.role = wesnoth.get_dialog_value "textbox_role"
				-- checkbuttons
				temp_table.poisoned = wesnoth.get_dialog_value "poisoned_checkbutton"
				temp_table.slowed = wesnoth.get_dialog_value "slowed_checkbutton"
				temp_table.petrified = wesnoth.get_dialog_value "petrified_checkbutton"
				temp_table.invulnerable = wesnoth.get_dialog_value "invulnerable_checkbutton"
				temp_table.uncovered = wesnoth.get_dialog_value "uncovered_checkbutton"
				temp_table.guardian = wesnoth.get_dialog_value "guardian_checkbutton"
				temp_table.unhealable = wesnoth.get_dialog_value "unhealable_checkbutton"
				temp_table.stunned = wesnoth.get_dialog_value "stunned_checkbutton"
				-- alignment radiobutton
				local alignments = { "lawful", "neutral", "chaotic", "liminal" }
				temp_table.alignment = alignments[ wesnoth.get_dialog_value ( "alignment_listbox" ) ]
				-- put facing here
				local facings = { "nw", "ne", "n", "sw", "se", "s" }
				-- wesnoth.get_dialog_value ( "facing_listbox" ) returns a number, that was 2 for the second radiobutton and 5 for the fifth, hence the table above
				temp_table.facing = facings[ wesnoth.get_dialog_value ( "facing_listbox" ) ] -- it is setted correctly, but for some reason it is not shown
				-- misc; checkbuttons
				temp_table.resting = wesnoth.get_dialog_value "resting_checkbutton"
				temp_table.hidden = wesnoth.get_dialog_value "hidden_checkbutton"
			end

			local return_value = wesnoth.show_dialog( debug_dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end

		local return_table = wesnoth.synchronize_choice(sync)
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
			-- we do this empty table/gmatch/insert cycle, because get_dialog_value returns a string from a text_box, and the value required is a "table with unnamed indices holding strings"
			-- moved here because synchronize_choice needs a WML object, and a table with unnamed indices isn't
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
			wesnoth.delay(1)
			-- fire events if needed
			if lua_dialog_unit.hitpoints <= 0 then -- do not try to advance a dead unit
				wml_actions.kill( { id = lua_dialog_unit.id, animate = true, fire_event = true } )
			elseif lua_dialog_unit.experience >= lua_dialog_unit.max_experience then
				wml_actions.store_unit { { "filter", { id = lua_dialog_unit.id } }, variable = "Lua_store_unit", kill = true }
				wml_actions.unstore_unit { variable = "Lua_store_unit", find_vacant = false, advance = true, fire_event = true }
				wesnoth.set_variable ( "Lua_store_unit")
			end
			-- finally, redraw to be sure of showing changes
			wml_actions.redraw {}
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.message( tostring( _"Quick Debug" ), tostring( _"Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
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
	local side_unit = wesnoth.get_units ( { x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1 } )[1]
	if side_unit and side_unit.valid then
		local side_number = side_unit.side -- clearly, at x1,y1 there could be only one unit

		local lua_dialog_side = wesnoth.sides[side_number]

		-- experimenting with macrowidgets... sort of
		--buttonbox
		local buttonbox = T.grid {
					T.row {
						T.column {
							T.button {
								label = _"OK",
								return_value = 1
							}
						},
						T.column {
							T.spacer {
								width = 10
							}
						},
						T.column {
							T.button {
								label = _"Cancel",
								return_value = 2
							}
						}
					}
				}

		-- read-only labels
		-- fields here: side number, total_income, fog, shroud, hidden, name, color
		local read_only_panel = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									definition = "default_large",
									label = _"Side"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									definition = "default_large",
									id = "side_number_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Total income"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									id = "total_income_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Fog"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									id = "fog_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Shroud"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									id = "shroud_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Name"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									id = "name_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Faction"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									id = "faction_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Faction name"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.label {
									id = "faction_name_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _"Flag"
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.image {
									id = "flag_image"
								}
							}
						}
					}

		-- controller radiobutton
		-- values here: ai, human, null, human_ai, network, network_ai
		local radiobutton = T.horizontal_listbox {
					id = "controller_listbox",
					T.list_definition {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "controller_radiobutton",
									definition = "radio"
								}
							}
						}
					},
					T.list_data {
						T.row {
							T.column {
								label = _"ai"
							}
						},
						T.row {
							T.column {
								label = _"human"
							}
						},
						T.row {
							T.column {
								label = _"human_ai"
							}
						},
						T.row {
							T.column {
								label = _"network"
							}
						},
						T.row {
							T.column {
								label = _"network_ai"
							}
						},
						T.row {
							T.column {
								label = _"null"
							}
						}
					}
				}

		-- defeat conditions radiobutton
		-- values: no leader/no unit/never/always
		local defeat_radio = T.horizontal_listbox {
					id = "defeat_condition_listbox",
					T.list_definition {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "defeat_condition_radiobutton",
									definition = "radio"
								}
							}
						}
					},
					T.list_data {
						T.row {
							T.column {
								label = _"No leaders left"
							}
						},
						T.row {
							T.column {
								label = _"No units left"
							}
						},
						T.row {
							T.column {
								label = _"Never"
							}
						},
						T.row {
							T.column {
								label = _"Always"
							}
						}
					}
				}
		
		-- various checkbuttons
		local misc_checkbuttons = T.grid {
					T.row {
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.toggle_button {
								id = "objectives_changed_checkbutton",
								label = _ "Objectives changed"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.toggle_button {
								id = "hidden_checkbutton",
								label = _ "Hidden"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.toggle_button {
								id = "scroll_to_leader_checkbutton",
								label = _ "Scroll to leader"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.toggle_button {
								id = "lost_checkbutton",
								label = _ "Lost"
							}
						}
					}
				}

		-- modifications panel
		-- fields here: gold, village_gold, base_income, user_team_name, objectives_changed, hidden,
		-- scroll_to_leader, lost, defeat_condition, team_name, controller, color
		local modify_panel = T.grid {
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Gold"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, lua_dialog_side.gold ),
								maximum_value = math.max( 1000, lua_dialog_side.gold ),
								step_size = 1,
								id = "side_gold_slider"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Village gold"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, lua_dialog_side.village_gold ),
								maximum_value = math.max( 10, lua_dialog_side.village_gold ),
								step_size = 1,
								id = "side_village_gold_slider"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Village support"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, lua_dialog_side.village_support ),
								maximum_value = math.max( 10, lua_dialog_side.village_support ),
								step_size = 1,
								id = "side_village_support_slider"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Base income"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( -2, lua_dialog_side.base_income ),
								maximum_value = math.max( 18, lua_dialog_side.base_income ),
								step_size = 1,
								id = "side_base_income_slider"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"User team name"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "user_team_name_textbox",
								history = "other_user_team_names"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Misc"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							misc_checkbuttons
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Defeat condition"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							defeat_radio
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Team name"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "team_name_textbox",
								history = "other_team_names"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Color"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "side_color_textbox",
								history = "side_color_history"
								-- this interferes with the map labels!
								-- tooltip = _"Supported values for mainline are numbers (1-9)\nor the following color names:\nred, blue, green, purple, black, brown, orange, white, teal"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Recruit"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "recruit_textbox",
								history = "history_recruits"
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _"Controller"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							radiobutton
						}
					}
				}

		local side_dialog = {
			T.helptip { id="tooltip_large" }, -- mandatory field
			T.tooltip { id="tooltip_large" }, -- mandatory field
			maximum_height = 600,
			maximum_width = 800,
			T.grid { -- Title
				T.row {
					T.column {
						horizontal_alignment = "left",
						grow_factor = 1,
						border = "all",
						border_size = 5,
						T.label {
							definition = "title",
							label = _"Side Debug Menu"
						}
					}
				},
				-- Subtitile
				T.row {
					T.column {
						horizontal_alignment = "left",
						border = "all",
						border_size = 5,
						T.label {
							label = _"Set the desired parameters, then press OK to confirm or Cancel to exit"
						}
					}
				},
				T.row {
					T.column {
						T.grid {
							T.row {
								T.column {
									vertical_alignment = "top",
									read_only_panel
								},
								T.column {
									modify_panel
								}
							}
						}
					}
				},
				T.row {
					T.column {
						buttonbox
					}
				}
			}
		}

		local function preshow()
			-- set widget values
			-- read-only labels
			wesnoth.set_dialog_value ( lua_dialog_side.side, "side_number_label" )
			wesnoth.set_dialog_value ( lua_dialog_side.total_income, "total_income_label" )
			wesnoth.set_dialog_value ( lua_dialog_side.fog, "fog_label" )
			wesnoth.set_dialog_value ( lua_dialog_side.shroud, "shroud_label" )
			wesnoth.set_dialog_value ( lua_dialog_side.side_name, "name_label" )
			wesnoth.set_dialog_value ( lua_dialog_side.faction, "faction_label" )
			wesnoth.set_dialog_value ( lua_dialog_side.faction_name, "faction_name_label" )

			if lua_dialog_side.flag_icon == "" then
				wesnoth.set_dialog_value ( string.format( "flags/flag-icon.png~RC(flag_green>%s)", lua_dialog_side.color ), "flag_image" )
			else
				wesnoth.set_dialog_value ( string.format( "%s~RC(flag_green>%s)", lua_dialog_side.flag_icon, lua_dialog_side.color ), "flag_image" )
			end

			-- sliders
			wesnoth.set_dialog_value ( lua_dialog_side.gold, "side_gold_slider" )
			wesnoth.set_dialog_value ( lua_dialog_side.village_gold, "side_village_gold_slider" )
			wesnoth.set_dialog_value ( lua_dialog_side.base_income, "side_base_income_slider" )
			wesnoth.set_dialog_value ( lua_dialog_side.village_support, "side_village_support_slider" )
			-- text boxes
			--wesnoth.set_dialog_value ( lua_dialog_side.objectives, "side_objectives_textbox" )
			wesnoth.set_dialog_value ( lua_dialog_side.user_team_name, "user_team_name_textbox" )
			wesnoth.set_dialog_value ( lua_dialog_side.team_name, "team_name_textbox" )
			wesnoth.set_dialog_value ( lua_dialog_side.color, "side_color_textbox" )
			wesnoth.set_dialog_value ( table.concat( lua_dialog_side.recruit, "," ), "recruit_textbox" )
			-- checkbuttons
			wesnoth.set_dialog_value ( lua_dialog_side.objectives_changed, "objectives_changed_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_side.scroll_to_leader, "scroll_to_leader_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_side.hidden, "hidden_checkbutton" )
			wesnoth.set_dialog_value ( lua_dialog_side.lost, "lost_checkbutton" )
			-- radiobutton
			local temp_controller

			if lua_dialog_side.controller == "ai" then
				temp_controller = 1
			elseif lua_dialog_side.controller == "human" then
				temp_controller = 2
			elseif lua_dialog_side.controller == "human_ai" then
				temp_controller = 3
			elseif lua_dialog_side.controller == "network" then
				temp_controller = 4
			elseif lua_dialog_side.controller == "network_ai" then
				temp_controller = 5
			elseif lua_dialog_side.controller == "null" then
				temp_controller = 6
			end
			wesnoth.set_dialog_value ( temp_controller, "controller_listbox" )
			
			if lua_dialog_side.defeat_condition == "no_leader_left" then
				wesnoth.set_dialog_value( 1, "defeat_condition_listbox" )
			elseif lua_dialog_side.defeat_condition == "no_units_left" then
				wesnoth.set_dialog_value( 2, "defeat_condition_listbox" )
			elseif lua_dialog_side.defeat_condition == "never" then
				wesnoth.set_dialog_value( 3, "defeat_condition_listbox" )
			elseif lua_dialog_side.defeat_condition == "always" then
				wesnoth.set_dialog_value( 4, "defeat_condition_listbox" )
			end
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow()
				-- get widget values
				-- sliders
				temp_table.gold = wesnoth.get_dialog_value ( "side_gold_slider" )
				temp_table.village_gold = wesnoth.get_dialog_value ( "side_village_gold_slider" )
				temp_table.base_income = wesnoth.get_dialog_value ( "side_base_income_slider" )
				temp_table.village_support = wesnoth.get_dialog_value ( "side_village_support_slider" )
				-- text boxes
				temp_table.user_team_name = wesnoth.get_dialog_value ( "user_team_name_textbox" )
				temp_table.team_name = wesnoth.get_dialog_value ( "team_name_textbox" )
				temp_table.recruit = wesnoth.get_dialog_value ( "recruit_textbox" )
				temp_table.color = wesnoth.get_dialog_value ( "side_color_textbox" )
				-- checkbuttons
				temp_table.objectives_changed = wesnoth.get_dialog_value ( "objectives_changed_checkbutton" )
				temp_table.scroll_to_leader = wesnoth.get_dialog_value ( "scroll_to_leader_checkbutton" )
				temp_table.hidden = wesnoth.get_dialog_value ( "hidden_checkbutton" )
				temp_table.lost = wesnoth.get_dialog_value ( "lost_checkbutton" )
				-- radiobuttons
				local controllers = { "ai", "human", "human_ai", "network", "network_ai", "null" }
				temp_table.controller = controllers[ wesnoth.get_dialog_value ( "controller_listbox" ) ]
				
				local defeat_conditions = { "no_leader_left", "no_units_left", "never", "always" }
				temp_table.defeat_condition = defeat_conditions[ wesnoth.get_dialog_value ( "defeat_condition_listbox" ) ]
			end

			local return_value = wesnoth.show_dialog( side_dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end
		local return_table = wesnoth.synchronize_choice(sync)
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
			lua_dialog_side.controller = temp_table.controller
			lua_dialog_side.defeat_condition = temp_table.defeat_condition
			lua_dialog_side.color = temp_table.color

			local temp_recruit = {}
			for value in wlp_utils.split( temp_table.recruit ) do
				table.insert( temp_recruit, wlp_utils.chop( value ) )
			end
			lua_dialog_side.recruit = temp_recruit
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.message( tostring( _"Side Debug" ), tostring( _"Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
		-- if user clicks on empty hex, do nothing
	end
end

-- [item_dialog]
-- an alternative interface to pick items
-- could be used in place of [message] with [option] tags
function wml_actions.item_dialog( cfg )
	local image_and_description = T.grid {
					T.row {
						T.column {
							vertical_alignment = "center",
							horizontal_alignment = "center",
							border = "all",
							border_size = 5,
							T.image {
								id = "image_name"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.scroll_label {
								id = "item_description"
							}
						}
					}
				}

	local buttonbox = T.grid {
				T.row {
					T.column {
						T.button {
							id = "take_button",
							return_value = 1
						}
					},
					T.column {
						T.spacer {
							width = 10
						}
					},
					T.column {
						T.button {
							id = "leave_button",
							return_value = 2
						}
					}
				}
			}

	local item_dialog = {
		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field
		maximum_height = 320,
		maximum_width = 480,
		T.grid { -- Title, will be the object name
			T.row {
				T.column {
					horizontal_alignment = "left",
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.label {
						definition = "title",
						id = "item_name"
					}
				}
			},
			-- Image and item description
			T.row {
				T.column {
					image_and_description
				}
			},
			-- Effect description
			T.row {
				T.column {
					horizontal_alignment = "left",
					border = "all",
					border_size = 5,
					T.label {
						wrap = true,
						id = "item_effect"
					}
				}
			},
			-- button box
			T.row {
				T.column {
					buttonbox
				}
			}
		}
	}

	local function item_preshow()
		-- here set all widget starting values
		wesnoth.set_dialog_markup( true, "item_description" )
		wesnoth.set_dialog_markup( true, "item_effect" )
		wesnoth.set_dialog_value ( cfg.name or "", "item_name" )
		wesnoth.set_dialog_value ( cfg.image or "", "image_name" )
		wesnoth.set_dialog_value ( cfg.description or "", "item_description" )
		wesnoth.set_dialog_value ( cfg.effect or "", "item_effect" )
		wesnoth.set_dialog_value ( cfg.take_string or helper.wml_error( "Missing take_string= key in [item_dialog]" ), "take_button" )
		wesnoth.set_dialog_value ( cfg.leave_string or helper.wml_error( "Missing leave_string= key in [item_dialog]" ), "leave_button" )
	end

	local function sync()
		local function item_postshow()
			-- here get all widget values
		end

		local return_value = wesnoth.show_dialog( item_dialog, item_preshow, item_postshow )

		return { return_value = return_value }
	end

	local return_table = wesnoth.synchronize_choice(sync)
	if return_table.return_value == 1 or return_table.return_value == -1 then
		wesnoth.set_variable ( cfg.variable or "item_picked", "yes" )
	else wesnoth.set_variable ( cfg.variable or "item_picked", "no" )
	end
end

-- the three tags below are WML/Lua remakes of Javascript's standard dialogs alert(), confirm() and prompt()
function wml_actions.alert( cfg )
	local alert_dialog = {
		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field
		maximum_height = 600,
		maximum_width = 800,
		T.grid { -- Title, will be the object name
			T.row {
				T.column {
					horizontal_alignment = "left",
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.label {
						definition = "title",
						id = "title"
					}
				}
			},
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					T.scroll_label {
						id = "message"
					}
				}
			},
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					T.button {
						label = "OK",
						return_value = 1
					}
				}
			}
		}
	}

	local function preshow()
		-- here set all widget starting values
		wesnoth.set_dialog_markup( true, "message" )
		wesnoth.set_dialog_value ( cfg.title or "", "title" )
		wesnoth.set_dialog_value ( cfg.message or "", "message" )
	end

	local function postshow()
		-- here get all widget values
	end
	wesnoth.show_dialog( alert_dialog, preshow, postshow )
	-- no syncronization, as we aren't interested in returned values
end

function wml_actions.confirm( cfg )
	local variable = cfg.variable or helper.wml_error( "Missing variable= key in [confirm]" )

	local buttonbox = T.grid {
				T.row {
					T.column {
						T.button {
							label = "OK",
							return_value = 1
						}
					},
					T.column {
						T.spacer {
							width = 10
						}
					},
					T.column {
						T.button {
							label = "Close",
							return_value = 2
						}
					}
				}
			}

	local confirm_dialog = {
		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field
		maximum_height = 600,
		maximum_width = 800,
		T.grid { -- Title, will be the object name
			T.row {
				T.column {
					horizontal_alignment = "left",
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.label {
						definition = "title",
						id = "title"
					}
				}
			},
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					T.scroll_label {
						id = "message"
					}
				}
			},
			-- button box
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					buttonbox
				}
			}
		}
	}

	local function preshow()
		-- here set all widget starting values
		wesnoth.set_dialog_markup( true, "message" )
		wesnoth.set_dialog_value ( cfg.title or "", "title" )
		wesnoth.set_dialog_value ( cfg.message or "", "message" )
	end

	local function sync()
		local function postshow()
			-- here get all widget values
		end

		local return_value = wesnoth.show_dialog( confirm_dialog, preshow, postshow )
		return { return_value = return_value }
	end

	local return_table = wesnoth.synchronize_choice(sync)
	local return_value = return_table.return_value

	if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter
		wesnoth.set_variable ( variable, true )
	elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc
		wesnoth.set_variable ( variable, false )
	else wesnoth.message( ( tostring( _"Confirm" ) .. ": " .. tostring( _"Error, return value :" ) .. return_value ) ) end -- any unhandled case is handled here
end

function wml_actions.prompt( cfg )
	local variable = cfg.variable or helper.wml_error( "Missing variable= key in [prompt]" )

	local buttonbox = T.grid {
				T.row {
					T.column {
						T.button {
							label = "OK",
							return_value = 1
						}
					},
					T.column {
						T.spacer {
							width = 10
						}
					},
					T.column {
						T.button {
							label = "Close",
							return_value = 2
						}
					}
				}
			}

	local prompt_dialog = {
		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field
		maximum_height = 600,
		maximum_width = 800,
		T.grid { -- Title, will be the object name
			T.row {
				T.column {
					horizontal_alignment = "left",
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.label {
						definition = "title",
						id = "title"
					}
				}
			},
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					T.scroll_label {
						id = "message"
					}
				}
			},
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					T.text_box {
						id = "text"
					}
				}
			},
			-- button box
			T.row {
				T.column {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					border = "all",
					border_size = 5,
					buttonbox
				}
			}
		}
	}

	local function preshow()
		-- here set all widget starting values
		wesnoth.set_dialog_markup( true, "message" )
		wesnoth.set_dialog_value ( cfg.title or "", "title" )
		wesnoth.set_dialog_value ( cfg.message or "", "message" )
		wesnoth.set_dialog_value ( cfg.text or "", "text" )
	end

	local function sync()
		local input

		local function postshow()
			-- here get all widget values
			input = wesnoth.get_dialog_value ( "text" )
		end

		local return_value = wesnoth.show_dialog( prompt_dialog, preshow, postshow )
		return { return_value = return_value, input = input }
	end

	local return_table = wesnoth.synchronize_choice(sync)
	local return_value = return_table.return_value

	if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter
		wesnoth.set_variable ( variable, return_table.input )
	elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc
		wesnoth.set_variable ( variable, "null" ) -- any better choice?
	else helper.wml_error( ( tostring( _"Prompt" ) .. ": " .. tostring( _"Error, return value :" ) .. tostring( return_value ) ) ) end -- any unhandled case is handled here
end

function wml_actions.choice_box( cfg )
	local variable = cfg.variable or helper.wml_error( "Missing variable= key in [choice_box]" )
	local choice_values = {} -- it will be populated by preshow, and supply values to postshow

	local buttonbox = T.grid {
				T.row {
					T.column {
						T.button { 
							label = _"OK",
							return_value = 1
						} 
					},
					T.column {
						T.spacer { width = 10 }
						},
					T.column {
						T.button {
							label = _"Cancel",
							return_value = 2
						}
					}
				}
			}

	local toggle_grid = T.grid {
				T.row {
					T.column {
						horizontal_alignment = "left",
						border = "all",
						border_size = 5,
						T.image {
							id = "choice_image",
							linked_group = "image"
							}
						},
					T.column {
						horizontal_alignment = "left",
						border = "all",
						border_size = 5,
						T.label {
							text_alignment = "left",
							id = "choice_description",
							linked_group = "description"
						}
					},
					T.column {
						horizontal_alignment = "right",
						border = "all",
						border_size = 5,
						T.label {
							text_alignment = "right",
							id = "choice_note",
							linked_group = "note"
						}
					}
				}
			}

	local listbox_dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		-- these linked groups are essential to ensure
		-- that all the items in the listbox are nicely aligned
		T.linked_group {
			id = "image",
			fixed_width = "true",
			fixed_height = "true"
		},
		T.linked_group {
			id = "description",
			fixed_width = "true",
			fixed_height = "true"
		},
		T.linked_group {
			id = "note",
			fixed_width = "true",
			fixed_height = "true"
		},
		maximum_height = 600,
		maximum_width = 800,
		T.grid {
			T.row {
				T.column {
					horizontal_alignment = "left",
					border = "all",
					border_size = 5,
					T.label {
						definition = "title",
						id = "window_title"
					}
				}
			},
			T.row {
				T.column {
					horizontal_alignment = "left",
					border = "all",
					border_size = 5,
					T.scroll_label {
						id = "window_message",
					}
				}
			},
			T.row {
				T.column {
					border = "all",
					border_size = 5,
					T.listbox {
						id = "choices_listbox",
						horizontal_grow = true,
						T.list_definition {
							T.row {
								T.column {
									horizontal_grow = true,
									T.toggle_panel {
										toggle_grid
									}
								}
							}
						}
					}
				}
			},
			T.row {
				T.column {
					buttonbox
				}
			}
		}
	}

	local function preshow()
		wesnoth.set_dialog_value( cfg.title, "window_title" )
		wesnoth.set_dialog_value( cfg.message, "window_message" )
		wesnoth.set_dialog_markup( true, "window_message" )
		
		local counter = 1
		for option in wml.child_range( cfg, "option") do
			if option.value then
				choice_values[counter] = option.value
			else
				choice_values[counter] = counter -- just the same number, for simplicity sake
			end
			wesnoth.set_dialog_value( option.image or "", "choices_listbox", counter, "choice_image" )
			wesnoth.set_dialog_value( option.description or "", "choices_listbox", counter, "choice_description" )
			wesnoth.set_dialog_markup( true, "choices_listbox", counter, "choice_description" )
			wesnoth.set_dialog_value( option.note or "", "choices_listbox", counter, "choice_note" )
			wesnoth.set_dialog_markup( true, "choices_listbox", counter, "choice_note" )
			counter = counter + 1
		end
	end
	local function sync()
		local choice_index
		local function postshow()
			choice_index = wesnoth.get_dialog_value( "choices_listbox" ) -- read the chosen option...
		end
		local return_value = wesnoth.show_dialog( listbox_dialog, preshow, postshow )
		return { return_value = return_value, choice = choice_values[choice_index] } -- and retrieve the associated value
	end

	local return_table = wesnoth.synchronize_choice(sync)
	local return_value = return_table.return_value

	if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter
		wesnoth.set_variable ( variable, return_table.choice )
	elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc
		wesnoth.set_variable ( variable, "null" ) -- any better choice?
	else helper.wml_error( ( tostring( _"Choice box" ) .. ": " .. tostring( _"Error, return value :" ) .. tostring( return_value ) ) ) end -- any unhandled case is handled here
end
