extends Node2D

var game_window: Rect2 # Game window
onready var grid: Grid = Grid.new()

# Parent sets `num_players` based on number of connected joysticks.
# Parent adjusts `num_players` when number of connected joysticks
# changes.
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

var rng = RandomNumberGenerator.new()

# Load the Player scene
const player_scene = preload("res://scenes/Player.tscn")

func _ready() -> void:
	game_window = get_viewport_rect()

	# Seed a random number generator for positioning blocks.
	rng.randomize() # setup the generator from a time-based seed

	# Add players to match number of connected joysticks. Parent
	# sets `num_players` based on number of connected joysticks.
	# If no parent, default to 4 joysticks for testing.
	for player_index in range(num_players):
		add_player(player_index)

	# DEBUGGING
	# print(game_window.size)
	# print(game_window.position.x)
	# print(game_window.end.x)


func game_grid() -> Rect2:
	# Divide game window into squares of side-length grid.size.
	# Return a `Rect2` that describes the game window as a grid.
	# Example:
	# If game_window is (0,0,1360,768) and tiles are 20 x 20
	# then game_grid is (0,0,67,37)
	# (0,0) is the top-left corner of the top-left-most tile.
	# (67,37) is the top-left corner of the bottom-right-most tile.
	#
	# Why is it end - 1?
	# In this example, (1360,768)/20 = (68,38).
	# This is the bottom-right corner of the screen.
	# The tile with its top-left corner starting at the
	# bottom-right corner of the screen is a tile that falls off
	# the screen!
	var game_grid := Rect2()
	game_grid.position.x = floor(game_window.position.x)
	game_grid.position.y = floor(game_window.position.y)
	game_grid.end.x = floor(game_window.end.x / grid.size) - 1
	game_grid.end.y = floor(game_window.end.y / grid.size) - 1
	print(game_grid)

	return game_grid


func random_position() -> Vector2:
	# Pick a random position quantized to the grid.
	var game_grid = game_grid()
	var random_tile = Vector2(
			rng.randi_range( # random x
					game_grid.position.x,
					game_grid.end.x),
			rng.randi_range( # random y
					game_grid.position.y,
					game_grid.end.y)
					)

	return random_tile * grid.size

func remove_player(player_index: int) -> void:
	# TODO: Remove the player. Or show in some way that the
	# player is inactive.
	# For now I leave the disconnected player on screen and
	# do nothing. The player is technically still "in play" and
	# other players can interact with it. But the player cannot
	# be controlled because the joystick is disconnected.
	# When the joystick reconnects, control is restored.
	players[player_index].player_block.color.a = 0.3
	pass

func add_player(player_index: int) -> void:
	# Add a player to the game.
	# `player_index` is the player's index in array `players`.
	# `player_index` is also the player's joystick device number.

	# First handle the corner case:
	# If a player disconnects and reconnects, the World already
	# knows about them. They are not a "new" player.
	# There information is still in the `players` array.
	# Therefore, instead of initializing like a "new" player, we
	# just want to revive this player.
	#
	# To catch this corner case, check if the player is "new".
	# The player is new if player_index == number of players so far.
	# If player_index is < number of players so far, this is an
	# "old" player. Even if the last player to join leaves the
	# game, the number of 
	if player_index < players.size():
		# TODO: add code to revive old player.
		# I'll need to "revive" once I've coded "removal."
		# For now I leave the disconnected player on screen and
		# do nothing, so there is nothing to do to "revive" the
		# player. They reconnect their joystick and they can move
		# again.
		players[player_index].player_block.color.a = 1
		return

	# Instantiate a new player.
	# Append the player instance to array `players`.
	players.append(player_scene.instance())

	# Refer to this just-added player as "player" for readability.
	var player = players[-1]

	# Make the player a child node of the World scene
	add_child(player)

	# Assign the joystick device number to this player.
	# (`player_index` is the player's joystick device number.)
	player.device_num = player_index

	# Randomize player's starting x,y position.
	# TODO: constrain random_position to the grid
	# player.player_block.top_left = random_position()
	player.position = random_position()

	# TODO: index at random into the list of colors so that I'm
	# not limited to 4 players.
	# TODO: let players change their color before the game begins.
	# Set the player's color
	var color_dict: Dictionary = {
		0: ColorN("magenta", 1), # color, alpha
		1: ColorN("lightseagreen", 1), # color, alpha
		2: ColorN("yellow", 1), # color, alpha
		3: ColorN("lightsalmon", 1), # color, alpha
		}
	player.player_block.color = color_dict[player_index]

	# Create an input_map dict for this player's joystick.
	input_maps.append({
		"ui_right{n}".format({"n":player_index}): Vector2.RIGHT,
		"ui_left{n}".format({"n":player_index}): Vector2.LEFT,
		"ui_up{n}".format({"n":player_index}): Vector2.UP,
		"ui_down{n}".format({"n":player_index}): Vector2.DOWN,
		})
		# DEBUGGING
		# print(input_maps[player_index])
	
	# Assign the input_map to this player.
	player.ui_inputs = input_maps[player_index]

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

	right_action = "ui_right{n}".format({"n":player_index})
	InputMap.add_action(right_action)
	# Creat a new InputEvent instance to assign to the InputMap.
	right_action_event = InputEventJoypadMotion.new()
	right_action_event.device = player_index
	right_action_event.axis = JOY_AXIS_0 # <---- horizontal axis
	right_action_event.axis_value =  1.0 # <---- right
	InputMap.action_add_event(right_action, right_action_event)

	left_action = "ui_left{n}".format({"n":player_index})
	InputMap.add_action(left_action)
	# Creat a new InputEvent instance to assign to the InputMap.
	left_action_event = InputEventJoypadMotion.new()
	left_action_event.device = player_index
	left_action_event.axis = JOY_AXIS_0 # <---- horizontal axis
	left_action_event.axis_value = -1.0 # <---- left
	InputMap.action_add_event(left_action, left_action_event)

	up_action = "ui_up{n}".format({"n":player_index})
	InputMap.add_action(up_action)
	# Creat a new InputEvent instance to assign to the InputMap.
	up_action_event = InputEventJoypadMotion.new()
	up_action_event.device = player_index
	up_action_event.axis = JOY_AXIS_1 # <---- vertical axis
	up_action_event.axis_value = -1.0 # <---- up
	InputMap.action_add_event(up_action, up_action_event)

	down_action = "ui_down{n}".format({"n":player_index})
	InputMap.add_action(down_action)
	# Creat a new InputEvent instance to assign to the InputMap.
	down_action_event = InputEventJoypadMotion.new()
	down_action_event.device = player_index
	down_action_event.axis = JOY_AXIS_1 # <---- vertical axis
	down_action_event.axis_value =  1.0 # <---- down
	InputMap.action_add_event(down_action, down_action_event)
