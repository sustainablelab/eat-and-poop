extends Node2D

# TODO: add/drop players during game when joysticks are added/removed

# TODO: start in a title scene before entering World.

# TODO: make joystick mapping editable

# TODO: save joystick mapping to file -- load mapping from file
# if it exists for that player, otherwise default to the mapping
# I have now.

var world: Node2D

func _ready() -> void:
	# DEBUGGING
	# print(Input.get_connected_joypads())

	# Load the World scene
	var world_scene = preload("res://scenes/World.tscn")

	# Instantiate the World
	world = world_scene.instance()

	# Set number of players to number of joysticks
	world.num_players = Input.get_connected_joypads().size()

	# Make the world a child node of the Main scene
	add_child(world)

	# Detect when a joystick connects
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	# DEBUGGING
	# print("Input.connect return value: {val}".format({"val":_ret}))

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	# DEBUGGING
	if connected:
		print("Connected device {d}.".format({"d":device}))
	else:
		print("Disconnected device {d}.".format({"d":device}))

	if connected:
		# Update number of players to number of connected joysticks.
		world.num_players = Input.get_connected_joypads().size()

		# Add the player to the world. Use the device number as
		# the player index into the array of players.
		world.add_player(device)
		print("Added player index {d} to the world.".format({"d":device}))

	else:
		# Do not change the number of players when a player disconnects.
		# There is a chance the disconnected player wins the round.

		# TODO
		world.remove_player(device)
		print("Removed player index {d} from the world.".format({"d":device}))
