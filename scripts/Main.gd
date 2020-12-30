extends Node2D

# TODO: add/drop players during game when joysticks are added/removed

# TODO: start in a title scene before entering World.

# TODO: make joystick mapping editable

# TODO: save joystick mapping to file -- load mapping from file
# if it exists for that player, otherwise default to the mapping
# I have now.

func _ready() -> void:
	# DEBUGGING
	print(Input.get_connected_joypads())

	# Load the World scene
	var world_scene = preload("res://scenes/World.tscn")

	# Instantiate the World
	var world = world_scene.instance()

	# Set number of players to number of joysticks
	world.num_players = Input.get_connected_joypads().size()

	# Make the world a child node of the Main scene
	add_child(world)

