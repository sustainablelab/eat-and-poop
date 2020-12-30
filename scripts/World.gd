extends Node2D

var game_window: Rect2 # Game window

var num_players: int = 4 # number of joysticks connected
var players: Array = [] # array to hold player instances

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

	# Instantiate N players
	# TODO: Parent sets `num_players` based on number of connected joysticks
	for _each in range(num_players):
		players.append(player_scene.instance())
	# var player1 = player_scene.instance()
	# var player2 = player_scene.instance()

	# Make the players child nodes of the World scene
	for player in players:
		add_child(player)
	# add_child(player1)
	# add_child(player2)

	# Randomize starting x,y position of each player.
	for player in players:
		player.player_block.top_left = random_position()
	# player1.player_block.top_left = random_position()
	# player2.player_block.top_left = random_position()

	# Set the color of each player
	var color_dict: Dictionary = {
		0: ColorN("lightsalmon", 1), # color, alpha
		1: ColorN("yellow", 1), # color, alpha
		2: ColorN("lightseagreen", 1), # color, alpha
		3: ColorN("magenta", 1), # color, alpha
		}
	for player_num in range(num_players):
		players[player_num].player_block.color = color_dict[player_num]
	# player1.player_block.color = ColorN("lightsalmon", 1) # color, alpha
	# player2.player_block.color = ColorN("lightseagreen", 1) # color, alpha


func random_position() -> Vector2:
	return Vector2(
			rng.randf_range( # random x
					game_window.position.x,
					game_window.end.x),
			rng.randf_range( # random y
					game_window.position.y,
					game_window.end.y)
					)

