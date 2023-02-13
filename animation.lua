--[=[
[animate_path]
Author: Alarantalara (username on the Battle for Wesnoth forum)

animate_path is a new tag that allows for movement of an object along paths not restricted by the hex grid

NOTE: All images used should have a 72 pixel wide transparent border surrounding them.
The only exception is if you are using this tag to animate a sequence of images that do not move.

Required keys:
hex_x, hex_y: a sequence of reference hexes on the map for the animation.
image: The image or sequence of images to display. If the value of frames exceeds the number of images,
	the images will be displayed in a loop. The images must have a 72 pixel transparent border
	surrounding them to be displayed properly.
frame_length: the amount of time each frame will be visible in milliseconds

Optional keys:
x,y: a sequence of points relative to the center of the ocrresponding reference hex in pixels through which the animation will travel
	If there are more x,y values than hex_x,hex_y values, then the last hex values will be used for later x,y values
	If there are more hex_x,y values, then x,y are 0,0 for the extra hexes
frames (default: number of images specified in image): The number of frames to use in the animation.
	If it is not specified, then the number of images from image will be used to calculate the number of frames.
	The number of frames must be at least 2 (so including a single image in image and not including this attribute will not work).
linger (default: no): If yes, then the last image will remain visible after the animation completes.
	It may be removed using [remove_item].
transpose (default: no): if yes, then the interpolation methods marked function will calculate based on y-values rather than x-values
interpolation: (default: linear) The interpolation method used to travel between points.
	Allowed values are: linear, bspline, parabola, cubic_spline
Method Details:
	Methods marked (function) require that the x values (y values if transpose is yes) be distinct and sorted (increasing or decreasing)
		Currently this is not checked, provide points out of order at your own risk
	linear: Animation moves in a straight line between each set of points.
	bspline: requires that at least 4 points be specified. Animation moves within a curve
			bounded by the points. It usually will not pass exactly through any point.
			It is currently the only method that produces curves that can form spirals or overlapping shapes.
	parabola (function): requires exactly 3 points be specified. The animation moves along the
			unique parabola that includes the specified points.
	cubic_spline (function): Animation moves along a curved path passing through each point.
			It is not possible to double back.
[extra_path]: Any number of extra_path tags may be included. Each one defines an additional animation to run at the same time.
	Extra animations have the same number of frames and start and end at the same time as the main animation.
	Available keys: hex_x,hex_y,x,y,image,linger,transpose,interpolation
	All keys have the same definition as the ones in the base animate_path tag.

Example:
[animate_path]
	x=0,100,1000
	y=0,0,1000
	hex_x=10
	hex_y=10
	image=the_image.png
	frames=20
	frame_length=20
[/animate_path]

Note for those who want more options:
This file returns a table of interpolation methods
You can add an initialization function to it to provide your own path function.
The initialization function receives an empty list to store state,
	a list of x values, a list of y values and the total number of locations
The number of x and y values are guaranteed to be the same

Your initialization function must a function that returns 3 functions:

The first function returns the length of each segment of the path, the number of segments and the total length of the path
It takes no parameters
<lengths>, num_lengths, total_length = length_function()
<lengths> must be an array indexed from [1..n] where n is the number of lengths
All lengths must be positive

The second function is called for each point of the path specified by the user
It takes one parameter specifying which segment in the path was reached (0..n where n is number of segments)
There are no return values

The third function is called containing the distance travelled along the current segment
This value will be in the range [0..length[segment_number]]
The function must return the absolute x,y coordinates of the associated point
x, y = get_point_on_current_segment_from_offset( offset )
]=]

-- Linear Algebra
local epsilon = 0.0000000001

local function solve_system(A, b)
	-- solve a system of n equations in n unknowns
	-- A is a square matrix
	local size = #A
	for i = 1,size do
		-- find largest element as pivot
		local largest = i
		for j = i,size do
			if math.abs(A[largest][i]) < math.abs(A[j][i]) then
				largest = j
			end
		end
		-- swap if larger element found
		if math.abs(A[largest][i]) < epsilon then
			-- largest element remaining is 0, no unique solution
			return nil
		end
		if largest ~= i then
			A[i], A[largest] = A[largest], A[i]
			b[i], b[largest] = b[largest], b[i]
		end
		-- reduce
		for k = i+1,size do
			local m = A[k][i] / A[i][i]
			for j = i+1,size do
				A[k][j] = A[k][j] - m * A[i][j]
			end
			b[k] = b[k] - m * b[i]
		end
	end

	-- back substitute
	for i = size,1,-1 do
		for j = size,i+1,-1 do
			b[i] = b[i] - A[i][j] * b[j]
		end
		b[i] = b[i] / A[i][i]
	end
	return b
end

-- Image Placement Functions

local function get_image_name_with_offset(x, y, image)
	-- since halo doesn't have a key to offset an image, use the CROP
	-- function built into the wesnoth image placement to fake it
	-- requires a 72 pixel border around the image to work properly
	x = math.floor(x*2)
	y = math.floor(y*2)
	local w, h = filesystem.image_size(image)

	w = w-math.abs(x)
	if w <= 0 then
		return
	end
	h = h-math.abs(y)
	if h <= 0 then
		return
	end
	if x > 0 then
		x = 0
	else
		x = -x
	end
	if y > 0 then
		y = 0
	else
		y = -y
	end
	return string.format("%s~CROP(%d,%d,%d,%d)",image,x,y,w,h)
end

local function calc_image_hex_offset(hex_x, hex_y, x, y)
	-- given a reference hex and an offset in pixels
	-- find the hex closest to the target and adjust the offset to be relative to that hex
	-- returns the new hex coordinates followed by the new pixel offset
	local hex_off_x = math.floor((x + 27) / 54)
	local k = 0
	if math.abs(hex_off_x) % 2 == 1 then
		if math.abs(hex_x) % 2 == 0 then
			k = 36
		else
			y = y - 36
		end
	end
	local hex_off_y = math.floor((y + 36) / 72)
	local new_x = x - hex_off_x * 54
	local new_y = y - (hex_off_y * 72) + k
	if new_y > 36 then
		new_y = new_y - 72
		hex_off_y = hex_off_y+1
	end

	return hex_x+hex_off_x, hex_y+hex_off_y, new_x, new_y
end

-- x and y are hex values in this function
local function calc_pixel_offset(x1, y1, x2, y2)
	local px = (x2 - x1)
	local py = (y2 - y1) * 72
	if math.abs(px) % 2 == 1 then
		if x2 % 2 == 1 then
			py = py - 36
		else
			py = py + 36
		end
	end
	px = px * 54
	return px, py
end

-- Miscellaneous Utilities

local function load_list(list)
	-- this loads a comma separated list into a 0-based array
	-- the 0 base simplifies later modular arithmetic
	local items = {}
	local num_items = 0
	for item in string.gmatch(list, "[^%s,][^,]*") do
		items[num_items] = item
		num_items = num_items + 1
	end
	return items, num_items
end

-- Interpolation Functions
local interpolation_methods = {}

function interpolation_methods.linear(state, x_locs, y_locs, num_locs)
	-- encapsulates the linear interpolation algorithm
	return function ()
		local function calc_linear_path_length()
			if num_locs == 1 then
				return {}, 0, 0
			end

			local total_length = 0
			local lengths = {}
			local last_x = x_locs[0]
			local last_y = y_locs[0]
			local cur_x, cur_y
			local num_lengths = 0
			for i = 1,num_locs-1 do
				cur_x = x_locs[i]
				cur_y = y_locs[i]
				lengths[i] = math.sqrt( (cur_x-last_x)^2 + (cur_y-last_y)^2 )
				total_length = total_length + lengths[i]
				last_x = cur_x
				last_y = cur_y
				num_lengths = num_lengths + 1
			end
			return lengths, num_lengths, total_length
		end

		local function reached_point(point)
			state.start_x = x_locs[point] or 0
			state.start_y = y_locs[point] or 0
			state.delta_x = (x_locs[point+1] or state.start_x) - state.start_x
			state.delta_y = (y_locs[point+1] or state.start_y) - state.start_y
		end

		local function get_location(offset)
			local x = (state.delta_x * offset) + state.start_x
			local y = (state.delta_y * offset) + state.start_y
			return x,y
		end

		return calc_linear_path_length, reached_point, get_location
	end
end

function interpolation_methods.bspline(state, x_locs, y_locs, num_locs )
	-- implements uniform cubic B-splines
	return function ()
		local function calc_uniform_path_length()
			local lengths = {}
			for i = 1,num_locs-3 do
				lengths[i] = 1
			end
			return lengths, num_locs-3, num_locs-3
		end

		local function reached_point(point)
			state.index = point
		end

		local function get_location(offset)
			local u3 = offset*offset*offset
			local u2 = offset*offset
			local u  = offset
			local b0 = (-1*u3 + 3*u2 - 3*u + 1)
			local b1 = ( 3*u3 - 6*u2       + 4)
			local b2 = (-3*u3 + 3*u2 + 3*u + 1)
			local b3 = u3

			local x = b0*x_locs[state.index] + b1*x_locs[state.index+1] + b2*x_locs[state.index+2]
			local y = b0*y_locs[state.index] + b1*y_locs[state.index+1] + b2*y_locs[state.index+2]
			if state.index < num_locs-3 then
				x = x + b3*x_locs[state.index+3]
				y = y + b3*y_locs[state.index+3]
			end
			return x/6, y/6
		end

		if num_locs < 4 then
			wml.error("[animate_path]: A B-spline path requires at least 4 points be specified")
		end

		return calc_uniform_path_length, reached_point, get_location
	end
end

function interpolation_methods.parabola(state, x_locs, y_locs, num_locs )
	-- implements simple parabolas
	-- assumes that the parabola opens up or down and that the points are specified in
	-- either increasing or decreasing order (second assumption allows determination of direction of travel)
	return function ()
		if num_locs ~= 3 then
			wml.error("[animate_path]: A parabola requires that exactly 3 points be specified")
		end
		local A
		A = {{x_locs[0]*x_locs[0], x_locs[0], 1},
			 {x_locs[1]*x_locs[1], x_locs[1], 1},
			 {x_locs[2]*x_locs[2], x_locs[2], 1}}
		state.b = {y_locs[0], y_locs[1], y_locs[2]} -- have to copy since input is 0-based
		state.b = solve_system(A, state.b)
		A = nil
		if state.b == nil then
			wml.error("[animate_path]: The provided points do not form a parabola")
		end

		local function get_parabola_path_length()
			return {1},1,1
		end

		local function reached_point(point)
			state.index = point
		end

		local function get_location(offset)
			local x
			if state.index == 1 then
				x = x_locs[2]
			else
				x = offset*(x_locs[2] - x_locs[0]) + x_locs[0]
			end
			local y = state.b[1]*x*x + state.b[2]*x + state.b[3]
			return x, y
		end

		return get_parabola_path_length, reached_point, get_location
	end
end

function interpolation_methods.cubic_spline(state, x_locs, y_locs, num_locs )
	-- implements natural cubic spline interpolation
	return function ()
		if num_locs <= 2 then
			return interpolation_methods.linear( x_locs, y_locs, num_locs )
		end

		local M = {}
		local mt = {__index = function () return 0 end}
		state.a = {}
		state.b = {}
		state.c = {}
		state.h = {}

		for i = 1,num_locs-1 do
			state.h[i] = x_locs[i] - x_locs[i-1]
		end
		for i = 1,num_locs-2 do
			M[i] = {}
			setmetatable(M[i], mt)
			M[i][i-1] = state.h[i] / 6
			M[i][i] = (state.h[i] + state.h[i+1]) / 3
			M[i][i+1] = state.h[i+1] / 6
			state.a[i] = (y_locs[i+1] - y_locs[i]) / state.h[i+1] - (y_locs[i] - y_locs[i-1]) / state.h[i]
		end
		-- TODO: write tridiagonal solver using the Thomas method to improve runtime
		-- O(n) instead of O(n^2)
		-- for now, use metatables to fill in all the 0s the Gaussian solver needs

		state.a = solve_system(M, state.a)
		M = nil
		state.a[0] = 0
		state.a[num_locs-1] = 0
		for i = 1,num_locs-1 do
			state.b[i] = y_locs[i-1] / state.h[i] - (state.a[i-1] * state.h[i]) / 6
			state.c[i] = y_locs[i] / state.h[i] - (state.a[i] * state.h[i]) / 6
		end

		local function get_cubic_path_length()
			-- since I don't want to calculate the arc length at this time
			-- I currently just return the absolute value of the
			-- x differences to provide a constant x-velocity
			local total_length = 0
			local lengths = {}
			local num_lengths = 0
			for i = 1,num_locs-1 do
				lengths[i] = math.abs(x_locs[i]-x_locs[i-1])
				total_length = total_length + lengths[i]
				num_lengths = num_lengths + 1
			end
			return lengths, num_lengths, total_length
		end

		local function reached_point(point)
			state.index = point+1
			state.delta_x = (x_locs[point+1] - x_locs[point]) or 0
		end

		local function get_location(offset)
			local x = (state.delta_x * offset) + x_locs[state.index-1]
			local y = state.a[state.index-1] * (x_locs[state.index] - x)^3 / (6 * state.h[state.index]) +
					  state.a[state.index] * (x - x_locs[state.index-1])^3 / (6 * state.h[state.index]) +
					  state.b[state.index] * (x_locs[state.index] - x ) +
					  state.c[state.index] * (x - x_locs[state.index-1])
			return x, y
		end

		return get_cubic_path_length, reached_point, get_location
	end
end

local function load_path(cfg, container_name)
	local animation = {}
	local temp = cfg.image or wml.error(container_name.." missing required image= attribute")
	animation.images, animation.num_images = load_list(temp)
	animation.linger = cfg.linger
	temp = cfg.hex_x or wml.error(container_name..": missing required hex_x= attribute")
	local hex_x, hex_x_count = load_list(temp)
	animation.hex_x = hex_x[0]
	temp = cfg.hex_y or wml.error(container_name..": missing required hex_y= attribute")
	local hex_y, hex_y_count = load_list(temp)
	animation.hex_y = hex_y[0]
	if hex_x_count ~= hex_y_count then
		wml.error("The number of hex_x and hex_y values must be the same in "..container_name.." "..hex_x_count.." "..hex_y_count)
	end

	temp = cfg.x or "0"
	animation.x_locs, animation.num_locs = load_list(temp)
	temp = cfg.y or "0"
	animation.y_locs, animation.num_y_locs = load_list(temp)
	if animation.num_locs ~= animation.num_y_locs then
		wml.error("The number of x and y values must be the same in "..container_name)
	end
	animation.transpose = cfg.transpose

	local matching_points = math.min(animation.num_locs, hex_x_count)
	for i = 1, matching_points-1 do
		local off_x, off_y = calc_pixel_offset(animation.hex_x, animation.hex_y, hex_x[i], hex_y[i])
		animation.x_locs[i] = animation.x_locs[i] + off_x
		animation.y_locs[i] = animation.y_locs[i] + off_y
	end
	if animation.num_locs > matching_points then
		local off_x, off_y = calc_pixel_offset(animation.hex_x, animation.hex_y, hex_x[matching_points-1], hex_y[matching_points-1])
		for i = matching_points, animation.num_locs-1 do
			animation.x_locs[i] = animation.x_locs[i] + off_x
			animation.y_locs[i] = animation.y_locs[i] + off_y
		end
	elseif hex_x_count > matching_points then
		animation.num_locs = hex_x_count
		for i = matching_points, animation.num_locs-1 do
			animation.x_locs[i], animation.y_locs[i] = calc_pixel_offset(animation.hex_x, animation.hex_y, hex_x[i], hex_y[i])
		end
	end

	animation.interpolation = cfg.interpolation or "linear"
	if not interpolation_methods[animation.interpolation] then
		wml.error(container_name..": Unknown interpolation method: "..animation.interpolation)
	end
	if animation.transpose then
		animation.x_locs, animation.y_locs = animation.y_locs, animation.x_locs
	end

	animation.state = {}
	local initialize = interpolation_methods[animation.interpolation](animation.state, animation.x_locs, animation.y_locs, animation.num_locs)
	animation.calc_path_length, animation.reached_point, animation.get_location = initialize()
	animation.lengths, animation.num_lengths, animation.total_length = animation.calc_path_length()

	animation.length_seen = 0
	animation.next_point = 1

	return animation
end

function wesnoth.wml_actions.animate_path(cfg)
	if filesystem.image_size == nil then
		wesnoth.interface.add_chat_message("Animation skipped. To see the animation, upgrade to Battle for Wesnoth version 1.15.14 or later")
		return
	end
	local animation = {}
	animation[1] = load_path(cfg, "[animate_path]")
	local frames = tonumber(cfg.frames) or animation[1].num_images
	if frames < 2 then
		wml.error("[animate_path] requires frames be at least 2")
	end
	local delay = tonumber(cfg.frame_length) or wml.error("Missing required frame_length= attribute in [animate_path]")
	local num_animations = 1
	for extra_path in wml.child_range(cfg, "extra_path") do
		num_animations = num_animations + 1
		animation[num_animations] = load_path(extra_path, "[extra_path]")
	end

	-- subtract 1 from frames to avoid fencepost problems
	frames = frames - 1
	for i = 1, num_animations do
		animation[i].length_per_frame = animation[i].total_length / frames
		animation[i].reached_point(0)
	end
	local x, y, cur_offset

	for i = 0, frames do
		for j = 1, num_animations do
			cur_offset = i * animation[j].length_per_frame - animation[j].length_seen
			while animation[j].next_point <= animation[j].num_lengths and cur_offset > animation[j].lengths[animation[j].next_point] do
				animation[j].reached_point(animation[j].next_point)
				cur_offset = cur_offset - animation[j].lengths[animation[j].next_point]
				animation[j].length_seen = animation[j].length_seen + animation[j].lengths[animation[j].next_point]
				animation[j].next_point = animation[j].next_point + 1
			end
			if animation[j].next_point <= animation[j].num_lengths then
				cur_offset = cur_offset / animation[j].lengths[animation[j].next_point]
			else
				-- avoid rounding error at end of path
				cur_offset = 0
			end
			x, y = animation[j].get_location(cur_offset)
			if animation[j].transpose then
				x, y = y, x
			end
			local target_hex_x, target_hex_y
			target_hex_x, target_hex_y, x, y = calc_image_hex_offset(animation[j].hex_x,animation[j].hex_y, x, y)
			animation[j].target_hex_x, animation[j].target_hex_y = target_hex_x, target_hex_y
			animation[j].image_name = get_image_name_with_offset(x, y, animation[j].images[i%animation[j].num_images])
			wesnoth.interface.add_hex_overlay(target_hex_x, target_hex_y, {
				x = target_hex_x,
				y = target_hex_y,
				halo = animation[j].image_name})
		end
		wml.fire("redraw")
		wesnoth.interface.delay(delay)
		for j = 1, num_animations do
			wesnoth.interface.remove_hex_overlay(animation[j].target_hex_x, animation[j].target_hex_y, animation[j].image_name)
		end
	end
	for j = 1, num_animations do
		if animation[j].linger then
			wesnoth.interface.add_item_halo(animation[j].target_hex_x, animation[j].target_hex_y, animation[j].image_name)
		end
	end
end

return interpolation_methods
