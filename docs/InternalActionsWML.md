InternalActionsWML
==================

Table of Content
----------------

* [store_shroud]
* [save_map]
* [nearest_hex]
* [nearest_unit]
* [get\_unit\_defense]
* [absolute_value]
* [get\_numerical\_minimum]
* [get\_ratio\_as\_percentage]
* [get\_numerical\_maximum]
* [get_percentage]
* [get\_movement\_type]
* [reverse_value]
* [random_number]
* [get\_recruit\_list]

[store_shroud]
--------------

Stores a side's shroud data in a WML variable.

**[StandardSideFilter](http://wiki.wesnoth.org/StandardSideFilter):** do not use a [filter_side] sub-tag. The first matching side will have its shroud stored. If no side matches the supplied filter, a WML error will be raised.

**variable:** the variable where shroud data will be stored.

[save_map]
----------

Stores the scenario map in a WML variable.

**variable:** the variable where the map will be stored.

[nearest_hex]
-------------

Finds the nearest hex to another given hex, that matches the SLF.

**starting\_x, starting\_y:** the location that will be used as base for the calculation.

**[filter_location]:** [StandardLocationFilter](http://wiki.wesnoth.org/StandardLocationFilter), all the locations matching the filter will be compared to the one specified above.

**variable:** the resulting nearest location will be stored in a WML variable with the given name, default is `nearest_hex`.

[nearest_unit]
--------------

Finds the nearest unit to a given hex, that matches the SUF.

**starting\_x, starting\_y:** the location that will be used as base for the calculation.

**[filter]:** [StandardUnitFilter](http://wiki.wesnoth.org/StandardUnitFilter), all the units matching the filter will be compared to the hex specified above.

**variable:** the resulting nearest unit will be stored in a WML variable with the given name, default is `nearest_unit`.

[get_unit_defense]
--------------------

Stores the defensive percentage of a unit on its current hex in a WML variable.

**[StandardUnitFilter](http://wiki.wesnoth.org/StandardUnitFilter):** Do not use a [filter] sub-tag. All the units matching the filter will be checked.

**variable:** the variable where the results will be stored, default name is `defense`. Every element of the array will contain the following keys: `id` (the unit's id), `x` and `y` (the unit's location), `terrain` (the terrain where the unit is), `defense` (the current unit's defense).

[absolute_value]
----------------

**Deprecated tag.** Use `[set_variable] abs=` instead.

Converts the value of the supplied variable to its absolute value (that is, removing the minus sign if the number has it).

**variable:** required. Its content will be converted to its absolute value.

**result_variable:** The resulting value will be stored here. If not supplied, the resulting value will be stored in the same variable supplied as argument for the `variable=` key.

[get_numerical_minimum]
-----------------------

**Deprecated tag.** Use `[set_variable] min=` instead.

Given a list of values, stores in a variable the lowest one.

**values:** a comma separated list of the values that will be compared. Non numerical values will be ignored.

**result_variable:** required. The lowest value will be stored here.

[get_numerical_maximum]
-----------------------

**Deprecated tag.** Use `[set_variable] max=` instead.

Given a list of values, stores in a variable the highest one.

**values:** a comma separated list of the values that will be compared. Non numerical values will be ignored.

**result_variable:** required. The highest value will be stored here.

[get_percentage]
----------------

Given a value (example: 20) and a percentage (example: 50), stores in a variable resulting value (example: 10).

**value:** required. The value from which the percentage will be calculated.

**percentage:** required. Do not use the % sign.

**variable:** required. The variable where the result will be stored.

[get_ratio_as_percentage]
-------------------------

Converts a ratio as a percent value, and stores the result in a variable.

**numerator, denominator:** required. The fraction to convert. Do not use the / (slash) sign, unless you want to use the FormulaAI notation

**variable:** required. The variable where the result will be stored.

[get_movement_type]
-------------------

Stores the movement type of the unit matching the filter inside a variable with the given name. If more than one unit matches the filter, only the first one is chosen.

**[StandardUnitFilter](http://wiki.wesnoth.org/StandardUnitFilter):** Do not use a [filter] sub-tag.

**variable:** the variable name where the movement type will be stored, if no value is supplied `movement_type` will be used as default name.

[reverse_value]
---------------

**Deprecated tag.** Use `[set_variable] reverse=yes` instead.

Reverses the value of the supplied variable, as in string reversal.

**variable:** required. Its content will be reversed.

**result_variable:** The reversed value will be stored here. If not supplied, the reversed value will be stored in the same variable supplied as argument for the `variable=` key.

[random_number]
---------------

**Deprecated tag.** Use `[set_variable] rand=` instead.

Sets a variable containing a randomly generated integer number. This tag relies upon Lua's RNG rather than on WML's RNG. **Warning:** this tag, due to some engine limitations, does not work on non multiplayer-synchronized events. For this reason, if you're planning to use it in a start or prestart event, you should use a _turn 1_ event instead - even in single player campaigns.

**lowest, highest:** required, these are the limits between which the random numer will be enclosed.

**variable:** the variable where said number will be stored, default value is `random`.

[get_recruit_list]
------------------

Retrieves and stores in a variable the recruitment list for each matching side. If a SUF is supplied, also the units recruitable by matching leaders `(extra_recruit)` are added to the list.

**[filter_side]:** [StandardSideFilter](http://wiki.wesnoth.org/StandardSideFilter), required. The recruit list will be acquired from every matching side.

**[filter]:** [StandardUnitFilter](http://wiki.wesnoth.org/StandardUnitFilter). If present, every matching leader will be checked for its `extra_recruit` key, and such recruits will be added to the list.

**variable:** default is `recruit_list`. It will contain an array with the following attributes of the side: `side` (the side's number), `team_name, user_team_name, name, recruit_list`.
