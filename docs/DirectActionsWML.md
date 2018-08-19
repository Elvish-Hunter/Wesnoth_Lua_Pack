DirectActionsWML
================

Table of Content
----------------

* [set_shroud]
* [load_map]
* [slow]
* [poison]
* [unslow]
* [unpoison]
* [scatter_units]
* [loot]

[set_shroud]
------------

Sets a side's shroud data to the one specified in this tag.

**[StandardSideFilter] (http://wiki.wesnoth.org/StandardSideFilter):** do not use a [filter\_side] sub-tag. The first matching side will have its shroud set. If no side matches the supplied filter, a WML error will be raised.

**shroud_data:** the shroud data that will be set. It could also be a variable created by [store_shroud].

[load_map]
----------

Replaces the scenario map with the one stored in a WML variable by [save_map].

**variable:** the variable containing the map to load.

[slow]
------

Slows all the units matching the filter, floating also the _"slowed"_ label.

**[StandardUnitFilter] (http://wiki.wesnoth.org/StandardUnitFilter):** do not use a [filter] sub-tag.

[poison]
--------

Poisons all the units (except non living units, like Undead) matching the filter, floating also the _"poisoned"_ label.

**[StandardUnitFilter] (http://wiki.wesnoth.org/StandardUnitFilter):** do not use a [filter] sub-tag.

[unslow]
--------

Unslows all the units matching the filter.

**[StandardUnitFilter] (http://wiki.wesnoth.org/StandardUnitFilter):** do not use a [filter] sub-tag.

[unpoison]
----------

Unpoisons all the units matching the filter.

**[StandardUnitFilter] (http://wiki.wesnoth.org/StandardUnitFilter):** do not use a [filter] sub-tag.

[scatter_units]
---------------

Randomly places the specified units on the locations matching the filter. Replacement for `{SCATTER_UNITS}` macro.

**[filter_location]:** [StandardLocationFilter] (http://wiki.wesnoth.org/StandardLocationFilter), required. Units will be placed in locations matching the filter. **Warning:** if you set up an incorrect filter (like, for example, not removing those hexes that will be impassable for the units that you want to place), respect of scatter_radius (below) may not be guaranteed.

**unit_types:** required. If you specify more than one type (comma-separated list), each placed units will be of one of the specified types, _randomly chosen_. The `SCATTER_UNITS` macro, instead, _cycles through the supplied list_: bear this in mind if you relied on such behaviour.

**units:** required, it is the amount of units to place. They may not be placed all if there are no more locations matching the filter available.

**scatter_radius:** if present, each unit will be placed at the given distance from the other units already placed by this tag.

**[wml]:** if present, the specified WML will be embedded in each unit placed by the tag.

[loot]
------

Assigns a certain amount of gold to each side matching the filter, displaying a message and playing a sound. Replacement for mainline `{LOOT}` macro.

**[StandardSideFilter] (http://wiki.wesnoth.org/StandardSideFilter):** do not use a [filter\_side] sub-tag. Every matching side will have its gold increased by the specified amount.

**amount:** required, the amount of gold that each side will gain.
