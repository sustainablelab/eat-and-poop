extends Node2D
var DEBUGGING = true
var game_window: Rect2 # Game window
onready var grid: Grid = Grid.new()

# World emits signal when joystick connects.
signal disconnected
signal connected

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

# _draw() runs once, sometime shortly after _ready() runs
# TODO: why is their a delay in responding to motion input when
# DEBUGGING_GRID = true?
var DEBUGGING_GRID = false
func _draw() -> void:
	# gridlines()
	if DEBUGGING_GRID:
		for point in gridpoints():
			draw_circle(
				point, # position
				grid.SIZE/6.0, # radius
				ColorN("black", 0.3) # color 
				)

# TEMPORARY FIX FOR USING KEYBOARD
onready var use_keyboard: bool = false

func _ready() -> void:
	# Inherit parent.DEBUGGING if this scene is not the entry point.
	var parent_node: Node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING

	game_window = get_viewport_rect()

	if DEBUGGING:
		print("Running {n}._ready()... Grid is {s} x {s} pixels in a {w} window.".format({
			"n": name,
			"s": grid.SIZE,
			"w": game_window.size,
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
			}))


	# Seed a random number generator for positioning blocks.
	rng.randomize() # setup the generator from a time-based seed

	# Add players to match number of connected joysticks. Parent
	# sets `num_players` based on number of connected joysticks.
	# If no parent, default to 4 joysticks for testing.
	for player_index in range(num_players):
		add_player(player_index)
	
	# TEMPORARY FIX FOR USING KEYBOARD
	if num_players == 0:
		use_keyboard = true
		# for player_index in range(1):
		for player_index in range(4):
			add_player(player_index)




# func gridlines() -> void:
# 	# Draw grid lines
# 	# Define the endpoints.
# 	# PLACEHOLDER:
# 	draw_line(
# 		Vector2(20,100), # from
# 		Vector2(20,800), # to
# 		ColorN("magenta", 1) # color
# 		)


func gridpoints() -> Array:
	# Return grid intersections as an array of Vector2 points
	var game_grid = game_grid()
	# Add 2:
	# Add 1 because num cols is end.x + 1 and num rows is end.y + 1
	# Add another 1 to get final set of points at window bottom and right
	# (grid point is tile top-left)
	var cols: int = game_grid.end.x + 2
	var rows: int = game_grid.end.y + 2
	var points: Array = []
	for col in range(cols):
		for row in range(rows):
			points.append(Vector2(
					game_grid.position.x + grid.SIZE*col,
					game_grid.position.y + grid.SIZE*row
					))
	return points

func game_grid() -> Rect2:
	# Divide game window into squares of side-length grid.SIZE.
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
	game_grid.end.x = floor(game_window.end.x / grid.SIZE) - 1
	game_grid.end.y = floor(game_window.end.y / grid.SIZE) - 1
	# print(game_grid)

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

	return random_tile * grid.SIZE


func remove_player(player_index: int) -> void:
	# TODO: Remove the player. Or show in some way that the
	# player is inactive.
	# For now I leave the disconnected player on screen and
	# do nothing. The player is technically still "in play" and
	# other players can interact with it. But the player cannot
	# be controlled because the joystick is disconnected.
	# When the joystick reconnects, control is restored.
	emit_signal("disconnected", players[player_index].player_name)


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
		# TODO: change to property "player.connected" and
		# `Player` should be the one to interpret this as a
		# change in alpha. `World` should not know how `Player`
		# visualizes itself with `Block`.
		emit_signal("connected", players[player_index].player_name)
		return

	# Instantiate a new player.
	# Append the player instance to array `players`.
	players.append(player_scene.instance())

	# Refer to this just-added player as "player" for readability.
	var player = players[-1]

	# Randomize player's starting x,y position.

	if DEBUGGING: # TESTING
		# Random positions are annoying while testing.
		# Hardcode positions for player_index 0 and 1
		if player_index == 0:
			player.start_position = Vector2(grid.SIZE*4,grid.SIZE*4)
		elif player_index == 1:
			player.start_position = Vector2(grid.SIZE*6,grid.SIZE*4)
		elif player_index == 2:
			player.start_position = Vector2(grid.SIZE*4,grid.SIZE*6)
		elif player_index == 3:
			player.start_position = Vector2(grid.SIZE*6,grid.SIZE*6)
		else:
			player.start_position = random_position()

	else:
		player.start_position = random_position()

	# TODO: index at random into the list of colors so that I'm
	# not limited to 4 players.
	# TODO: let players change their color before the game begins.
	var colornames: Array = [
		"magenta",
		"lightseagreen",
		"yellow",
		"lightsalmon",
		]
	# DEBUGGING COLLSIONS: Debug -> Visible Collision Shapes
	# alpha < 1 to see Player's Area2D.
	var alpha = 1.0 # build
	# var alpha = 0.3 # debug
	# TODO: Why a dict? Make this an Array.
	# Set the player's color
	var color_dict: Dictionary = {
		0: ColorN(colornames[0], alpha), # color, alpha
		1: ColorN(colornames[1], alpha), # color, alpha
		2: ColorN(colornames[2], alpha), # color, alpha
		3: ColorN(colornames[3], alpha), # color, alpha
		}
	player.color = color_dict[player_index]
	# Identify players by their color.
	player.player_name = colornames[player_index]

	# SETUP COLLISION RESPONSES
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = player.connect("hit", self, "_on_hit")
	_ret = player.connect("double_hit", self, "_on_double_hit")

	# Create an input_map dict for this player's joystick/keyboard.
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

	if not use_keyboard:
		# Use controllers
		# Assign the joystick device number to this player.
		# (`player_index` is the player's joystick device number.)
		player.device_num = player_index


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

	else:
		# Use keyboard
		# Map to keys for four people on one keyboard.
		var arrows: Dictionary = {
			"key_right": KEY_RIGHT,
			"key_left":  KEY_LEFT,
			"key_up":    KEY_UP,
			"key_down":  KEY_DOWN,
			}
		var wasd: Dictionary = {
			"key_right": KEY_D,
			"key_left":  KEY_A,
			"key_up":    KEY_W,
			"key_down":  KEY_S,
			}
		var hjkl: Dictionary = {
			"key_right": KEY_L,
			"key_left":  KEY_H,
			"key_up":    KEY_K,
			"key_down":  KEY_J,
			}
		var uiop: Dictionary = {
			"key_right": KEY_P,
			"key_left":  KEY_U,
			"key_up":    KEY_O,
			"key_down":  KEY_I,
			}
		var keymaps: Dictionary = {
			0: arrows,
			1: wasd,
			2: hjkl,
			3: uiop,
			}

		var right_action: String
		var right_action_event: InputEventKey

		var left_action: String
		var left_action_event: InputEventKey

		var up_action: String
		var up_action_event: InputEventKey

		var down_action: String
		var down_action_event: InputEventKey

		right_action = "ui_right{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventKey.new()
		right_action_event.scancode = keymaps[player_index]["key_right"]
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "ui_left{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventKey.new()
		left_action_event.scancode = keymaps[player_index]["key_left"]
		InputMap.action_add_event(left_action, left_action_event)

		up_action = "ui_up{n}".format({"n":player_index})
		InputMap.add_action(up_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		up_action_event = InputEventKey.new()
		up_action_event.scancode = keymaps[player_index]["key_up"]
		InputMap.action_add_event(up_action, up_action_event)

		down_action = "ui_down{n}".format({"n":player_index})
		InputMap.add_action(down_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		down_action_event = InputEventKey.new()
		down_action_event.scancode = keymaps[player_index]["key_down"]
		InputMap.action_add_event(down_action, down_action_event)

	# FINALLY: Now that player is all set up,
	# make the player a child node of the World scene
	add_child(player)


# Broadcast when one player hits another.
signal player_hit


func _on_hit(victim_name, collision_normal) -> void:
	emit_signal("player_hit", victim_name, collision_normal)

func _on_double_hit(player_name, player_direction) -> void:
	# Both players report. I only need one player_name from each.
	# Player direction is known from keypress.
	# If no key is pressed, expect Player sends a random value.
	emit_signal("player_hit", player_name, player_direction)
	if DEBUGGING:
		print("Double Hit!")
