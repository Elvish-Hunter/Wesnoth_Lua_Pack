InterfaceActionsWML
===================

Table of Content
----------------

* [narrate]
* [flash_color]
* [flash_screen]
* [fade\_to\_black]
* [fade\_to\_black\_hold]
* [fade_in]
* [fade\_to\_white]
* [fade\_to\_white\_hold]
* [fade\_in\_from\_white]
* [animate_path]
* [unknown_message]
* [show\_quick\_debug]
* [show\_side\_debug]
* [item_dialog]
* [whisper]
* [alert]
* [confirm]
* [prompt]
* [earthquake]
* [choice_box]

[narrate]
---------

Shows a message with `narrator` as speaker. All the standard keys and tags supported by [\[message\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bmessage.5D) are available, with two exceptions:

**speaker** is always equal to `narrator`;

**image** `wesnoth-icon.png` by default, if not present.

[flash_color]
-------------

Flashes the screen with the specified color.

**red, green, blue:** RGB value specifying the color required.

[flash_screen]
--------------

As `[flash_color]`, but accepts a color name as value.

**color:** the color in which the screen will flash. Currently supported values are `white, red, green, blue, magenta, fuchsia, yellow, cyan, aqua, purple, orange, black`.

[fade_to_black]
---------------

Fades the screen to black. Use `[fade_in]` to return to normal. It is a replacement for the `{FADE_TO_BLACK}` macro.

**interval:** this key controls the slowness of the fading. Use higher values to have a slower fading, default value is 5 milliseconds.

[fade_to_black_hold]
--------------------

Fades the screen to black and then pauses. Use `[fade_in]` to return to normal. It is a replacement for the `{FADE_TO_BLACK_HOLD}` macro.

**delay:** required, it is the pause duration, in milliseconds.

**interval:** this key controls the slowness of the fading. Use higher values to have a slower fading, default value is 5 milliseconds.

[fade_in]
---------

Brings the screen back from a `[fade_to_black]` or a `[fade_to_black_hold]`. It is a replacement for the `{FADE_IN}` macro.

**interval:** this key controls the slowness of the fading. Use higher values to have a slower fading, default value is 5 milliseconds.

[fade_to_white]
---------------

Fades the screen to white. Use `[fade_in_from_white]` to return to normal. It is equivalent to a theorical `{FADE_TO_WHITE}` macro.

**interval:** this key controls the slowness of the fading. Use higher values to have a slower fading, default value is 5 milliseconds.

[fade_to_white_hold]
--------------------

Fades the screen to white and then pauses. Use `[fade_in_from_white]` to return to normal. It is equivalent to a theorical `{FADE_TO_WHITE_HOLD}` macro.

**delay:** required, it is the pause duration, in milliseconds.

**interval:** this key controls the slowness of the fading. Use higher values to have a slower fading, default value is 5 milliseconds.

[fade_in_from_white]
--------------------

Brings the screen back from a `[fade_to_white]` `[fade_to_white_hold]`. It is equivalent to a theorical `{FADE_IN_FROM_WHITE}` macro.

**interval:** this key controls the slowness of the fading. Use higher values to have a slower fading, default value is 5 milliseconds.

[animate_path]
--------------

Move an image or cycle of images along a path not restricted by the map grid.

**x, y:** required. A list of points that control the movement. Points are specified in pixels and ranges are not accepted. For most interpolation methods, the animation will pass through the listed points. Some interpolation methods require a minimum number of points be specified.

**hex\_x, hex\_y:** required. The coordinates of the hex that the x and y coordinates will be relative to. 0,0 is the centre of this hex, with positive values for x and y up and to the right.

**image:** required. The image or sequence of images to display. If the value of `frames` exceeds the number of images, the images will be displayed in a loop. The images must have a 72 pixel transparent border surrounding them to be displayed properly.

**frame_length:** required. The amount of time each image will be displayed on screen in milliseconds.

**frames:** The number of frames to use in the animation. If it is not specified, then the number of `images` from image will be used to calculate the number of frames. The number of frames must be at least 2 (so including a single image in `image` and not including this attribute will not work).

**linger:** (default: no). If yes, then the last image will remain visible after the animation completes. It may be removed using [\[remove\_item\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bremove_item.5D).

**transpose:** (default: no). Interpolation methods marked function are normally based on the x coordinates. If this is yes, then they are based on the y coordinates. It has no effect on other interpolation methods.

**interpolation:** (default linear). The interpolation method used to travel between points. Allowed values are: `linear, bspline, parabola and cubic_spline`.

### Method Details

Methods marked (function) require that the x values (y values if `transpose` is yes) be distinct and sorted (increasing or decreasing). Currently this is not checked, provide points out of order at your own risk.

* **linear:** Animation moves in a straight line between each set of points.
* **bspline:** requires that at least 4 points be specified. Animation moves within a curve bounded by the points. It usually will not pass exactly through any point. It is currently the only method that produces curves that can form spirals or overlapping shapes.
* **parabola (function):** requires exactly 3 points be specified. The animation moves along the unique parabola that includes the specified points.
* **cubic_spline (function):** Animation moves along a curved path passing through each point. It is not possible to double back.

[unknown_message]
-----------------

Displays a message with the unknown unit icon as speaker portrait. Can team color the icon and set the caption.

**message:** required. The message to display, use exactly like in the [\[message\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bmessage.5D) tag.

**color:** if specified, the unknown unit icon will be team colored. Supported values are `red, lightred, darkred, blue, green, purple, black, brown, orange, white, teal` or integer numeric values between `1` and `9` (enclosed).

**right:** default no, if yes the unknown unit icon will be displayed on the right side of the screen.

**caption:** the text to display as speaker's name, use like in the [\[message\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bmessage.5D) tag.

**duration:** the minimum number of frames for the message to be displayed.

**side_for:** a comma-separated list of sides that determines which sides see the message.

**sound:** a sound effect to play as the message is shown. This can take a comma-separated list; a sound from such a list will be randomly chosen to be played.

[show_quick_debug]
------------------

When used inside a [\[set\_menu\_item\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bset_menu_item.5D), this tag allows modifying several unit attributes using the right-click menu. It displays a dialog where you can set hitpoints, moves, etc.

**This tag accepts no additional keys.** Usage:

    [set_menu_item]
        id=quick_debug
        description=Quick Debug
        [command]
            [show_quick_debug]
            [/show_quick_debug]
        [/command]
    [/set_menu_item]

[show_side_debug]
-----------------

When used inside a [\[set\_menu\_item\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bset_menu_item.5D), this tag allows modifying several side attributes using the right-click menu. It displays a dialog where you can set gold, income, etc.

**This tag accepts no additional keys.** Usage:

    [set_menu_item]
        id=side_debug
        description=Side Debug
        [command]
            [show_side_debug]
            [/show_side_debug]
        [/command]
    [/set_menu_item]

[item_dialog]
-------------

This tag shows a dialog box that can be used in place of the usual [message] with [option] tags. Upon the user's choice, it will set a variable that can be checked to see if the item was picked or not.

**name:** will be the dialog's title.

**image:** the image that will be displayed in the left side of the dialog. For Holy Water, for example, you can use `items/holy-water.png`.

**description:** a long description of the item. If it's too long, scrollbars will be automatically used. _This key supports Pango markup._

**effect:** very short description of the item's effects. For example: `"This staff grants a melee 5-2 impact magical attack"`. _This key supports Pango markup._
					**take_string:** required, this string will be displayed on the button that allows taking the item.

**leave_string:** required, this string will be displayed on the button that allows refusing the item.

**variable:** the resulting choice will be stored (as yes/no) in the variable specified here, default is `item_picked`.

[whisper]
---------

This tag shows a message in italic ans small font. It is meant as a replacement for both `{WHISPER}` and `{ASIDE}` macros.

**message:** the message to display, use exactly like in the [\[message\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bmessage.5D) tag.

**speaker:** speaker of the message, if no value is supplied _narrator_ is used by default.

**image:** the image that will be displayed at the side of this message, if no value is supplied _wesnoth-icon.png_ is used by default.

**caption:** the text to display as speaker's name, use like in the [\[message\]] (http://wiki.wesnoth.org/InterfaceActionsWML#.5Bmessage.5D) tag.

**duration:** the minimum number of frames for the message to be displayed.

**side_for:** a comma-separated list of sides that determines which sides see the message.

**sound:** a sound effect to play as the message is shown. This can take a comma-separated list; a sound from such a list will be randomly chosen to be played.

[alert]
-------

This tag is equivalent to Javascript's _alert_ standard dialog. It shows a message with a OK button. Does not return any value.

**title:** will be the dialog's title.

**message:** the shown message. _This key supports Pango markup._

[confirm]
---------

This tag is equivalent to Javascript's _confirm_ standard dialog. It shows a message with two buttons, OK and Close.

**title:** will be the dialog's title.

**message:** the shown message. _This key supports Pango markup._

**variable:** required, this variable will be set to yes (true) if OK is pressed, and to no (false) if Close is pressed.

[prompt]
--------

This tag is equivalent to Javascript's _prompt_ standard dialog. It shows a message with a text entry and two buttons, OK and Close.

**title:** will be the dialog's title.

**message:** the shown message. _This key supports Pango markup._

**variable:** required, this variable's content will be the text typed in the textbox if OK is pressed, or the string `null` if Close is closed.
				
[earthquake]
------------
Visuals and sound for an earth tremor. Replacement for the `{QUAKE}` macro.

**times:** the times that the earthquake will be repeated, default 1.

**delay:** the interval between each movement of the screen, default 50. Use higher numbers for a slower earthquake, lower numbers for a faster one.

[choice_box]
------------

This tag displays a window containing a listbox. Once that you choose one of the items, the resulting value will be stored.

**variable:** required, the value corresponding to the chosen item will be stored here. If you press Esc or the Cancel button, this variable will contain the string `null`.

**title:** the title of the window. _Pango markup is not supported here._

**message:** a string that will be printed just below the title. _This key supports Pango markup._

**[option]:** multiple tags allowed, it can contain the following keys:

* **image:** an image file, it will be displayed in the leftmost column.
* **description:** a string describing the option, it will be displayed in the central column. _This key supports Pango markup._
* **note:** a string useful to add additional information, like the cost of an item in gold pieces. It will be displayed in the rightmost column. _This key supports Pango markup._
* **value:** if this key is present, the associated value will be stored inside the variable indicated by the variable= key above. If this key isn't present, variable= will just contain the 1-based index of the chosen option.
