extends Node2D

var game_window: Rect2 # Game window

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

	# Instantiate two players
	# TODO: instantiate players based on number of connected
	# joysticks
	var player1 = player_scene.instance()
	var player2 = player_scene.instance()

	# Make the players child nodes of the World scene
	add_child(player1)
	add_child(player2)

	# Randomize starting x,y position of each player.
	player1.player_block.top_left = random_position()
	player2.player_block.top_left = random_position()

	# Set the color of each player
	player1.player_block.color = ColorN("lightsalmon", 1) # color, alpha
	player2.player_block.color = ColorN("lightseagreen", 1) # color, alpha


func random_position() -> Vector2:
	return Vector2(
			rng.randf_range( # random x
					game_window.position.x,
					game_window.end.x),
			rng.randf_range( # random y
					game_window.position.y,
					game_window.end.y)
					)

