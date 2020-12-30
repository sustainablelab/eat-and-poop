extends Node2D

var game_window: Rect2 # Game window

# Parent sets `num_players` based on number of connected joysticks.
#
# JOYSTICK DEVICE NUMBER:
# `range(num_players)` creates a sequence of numbers.
# The sequence has length `num_players` and starts at 0.
# -> This sequence matches the joystick device number when
# joysticks are attached:
# first  joystick is device 0,
# second joystick is device 1, etc.
#
# TESTING:
# Hardcode `num_players` to test `World.tscn` without a Parent.
# -> When the parent writes to `num_players`, it overrides the
# value here in `World.gd`.
var num_players: int = 4 # number of joysticks connected

var players: Array = [] # array to hold player instances
var input_maps: Array = [] # array to hold input_map dict for each player

# TODO: control each player from a different joystick
# can manually edit InputMap in the Project -> Settings, but this
# does not scale.
# Instead, use InputMap to assign new actions in script.
# Figure out how to assign those as the actions to the
# input-detection for the Player instance.

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	game_window = get_viewport_rect()

	# DEBUGGING
	print(game_window.size)
	print(game_window.position.x)
	print(game_window.end.x)

	# Seed a random number generator for positioning blocks.
	rng.randomize() # setup the generator from a time-based seed

	# Load the Player scene
	var player_scene = preload("res://scenes/Player.tscn")

	# Instantiate N players.
	# Append each player instance to array `players`.
	# Parent sets `num_players` based on number of connected joysticks
	for _each in range(num_players):
		players.append(player_scene.instance())
	# var player1 = player_scene.instance()
	# var player2 = player_scene.instance()

	# Make the players child nodes of the World scene
	for player in players:
		add_child(player)
	# add_child(player1)
	# add_child(player2)

	# Assign the joystick device number to each player.
	# TODO: rename player_num to player_index everywhere.
	for player_num in range(num_players):
		players[player_num].device_num = player_num

	# Randomize starting x,y position of each player.
	for player in players:
		player.player_block.top_left = random_position()
	# player1.player_block.top_left = random_position()
	# player2.player_block.top_left = random_position()

	# Set the color of each player
	var color_dict: Dictionary = {
		0: ColorN("magenta", 1), # color, alpha
		1: ColorN("lightseagreen", 1), # color, alpha
		2: ColorN("yellow", 1), # color, alpha
		3: ColorN("lightsalmon", 1), # color, alpha
		}
	for player_num in range(num_players):
		players[player_num].player_block.color = color_dict[player_num]
	# player1.player_block.color = ColorN("lightsalmon", 1) # color, alpha
	# player2.player_block.color = ColorN("lightseagreen", 1) # color, alpha

	# Create an input_map dict for each player to match their joystick.
	for player_num in range(num_players):

		# TEMPORARY FIX while manually editing InputMap
		# if player_num == 0:
		# 	input_maps.append({
		# 		"ui_right": Vector2.RIGHT,
		# 		"ui_left": Vector2.LEFT,
		# 		"ui_up": Vector2.UP,
		# 		"ui_down": Vector2.DOWN,
		# 		})
		# else:
		# 	input_maps.append({
		# 		"ui_right{n}".format({"n":player_num+1}): Vector2.RIGHT,
		# 		"ui_left{n}".format({"n":player_num+1}): Vector2.LEFT,
		# 		"ui_up{n}".format({"n":player_num+1}): Vector2.UP,
		# 		"ui_down{n}".format({"n":player_num+1}): Vector2.DOWN,
		# 		})

		# RIGHT WAY after script edits InputMap:
		input_maps.append({
			"ui_right{n}".format({"n":player_num}): Vector2.RIGHT,
			"ui_left{n}".format({"n":player_num}): Vector2.LEFT,
			"ui_up{n}".format({"n":player_num}): Vector2.UP,
			"ui_down{n}".format({"n":player_num}): Vector2.DOWN,
			})
		print(input_maps[player_num])
	
	# Assign the input_map to that player.
	for player_num in range(num_players):
		players[player_num].ui_inputs = input_maps[player_num]

	# Edit the InputMap to match the names used in the input_map assignments.
	# For example, default InputMap has name "ui_left".
	# I use the same default names but with a device number suffix.
	# So "ui_left" becomes "ui_left0", "ui_left1", etc.
	# These are called "actions". The joypad motion that triggers
	# the action is called an "action event".

	# CODE:
	# I create the String and the InputEventJoypadMotion in a
	# for loop so that there are unique instances of each.
	#
	# -> If I defined the InputEventJoypadMotion *outside* the
	# for loop, then there is only one instance is in memory.
	# Each time I updated this instance with settings for the
	# next player, the previous players are still "looking" at
	# that same instance, so by the end of the loop, all players
	# are controlled by the last controller connected. No good.
	#
	# For readability, I make variables to temporarily point to
	# the String that identifies the "action" and the
	# InputEventJoypadMotion that defines the "action event".
	# Also, I don't know how to set properities in the `new()`
	# method, so I need a variable to refer back to the
	# InputEventJoypadMotion to set its properties.

	var right_action: String
	var right_action_event: InputEventJoypadMotion

	var left_action: String
	var left_action_event: InputEventJoypadMotion

	var up_action: String
	var up_action_event: InputEventJoypadMotion

	var down_action: String
	var down_action_event: InputEventJoypadMotion

	for player_num in range(num_players):

		right_action = "ui_right{n}".format({"n":player_num})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventJoypadMotion.new()
		right_action_event.device = player_num
		right_action_event.axis = JOY_AXIS_0 # <---- horizontal axis
		right_action_event.axis_value =  1.0 # <---- right
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "ui_left{n}".format({"n":player_num})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventJoypadMotion.new()
		left_action_event.device = player_num
		left_action_event.axis = JOY_AXIS_0 # <---- horizontal axis
		left_action_event.axis_value = -1.0 # <---- left
		InputMap.action_add_event(left_action, left_action_event)

		up_action = "ui_up{n}".format({"n":player_num})
		InputMap.add_action(up_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		up_action_event = InputEventJoypadMotion.new()
		up_action_event.device = player_num
		up_action_event.axis = JOY_AXIS_1 # <---- vertical axis
		up_action_event.axis_value = -1.0 # <---- up
		InputMap.action_add_event(up_action, up_action_event)

		down_action = "ui_down{n}".format({"n":player_num})
		InputMap.add_action(down_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		down_action_event = InputEventJoypadMotion.new()
		down_action_event.device = player_num
		down_action_event.axis = JOY_AXIS_1 # <---- vertical axis
		down_action_event.axis_value =  1.0 # <---- down
		InputMap.action_add_event(down_action, down_action_event)

func random_position() -> Vector2:
	return Vector2(
			rng.randf_range( # random x
					game_window.position.x,
					game_window.end.x),
			rng.randf_range( # random y
					game_window.position.y,
					game_window.end.y)
					)

