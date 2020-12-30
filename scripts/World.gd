extends Node2D

var screen_size: Vector2 # Game window


func _ready() -> void:
	screen_size = get_viewport_rect().size
	print(screen_size)

	# Load the Player scene
	var player_scene = preload("res://scenes/Player.tscn")

	# Instantiate two players
	var player1 = player_scene.instance()
	var player2 = player_scene.instance()

	# Make the players child nodes of the World scene
	add_child(player1)
	add_child(player2)

	# Set the starting x,y position of each player
	var x:float
	var y:float
	x = 100.0
	y = 100.0
	player1.player_block.top_left = Vector2(x,y)
	x = 600.0
	y = 100.0
	player2.player_block.top_left = Vector2(x,y)

	# Set the color of each player
	player1.player_block.color = ColorN("lightsalmon", 1) # color, alpha
	player2.player_block.color = ColorN("lightseagreen", 1) # color, alpha
