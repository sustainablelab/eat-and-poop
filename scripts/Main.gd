extends Node2D

# Globally enable/disable DEBUGGING mode.
# I code all Children Nodes to check DEBUGGING.
var DEBUGGING = true

# TODO: start in a title scene before entering World.

# TODO: make joystick mapping editable
# TODO: make keyboard mapping editable

# TODO: save joystick/keyboard mapping to file -- load mapping
# from file if it exists for that player, otherwise default to
# the mapping I have now.

var world: Node2D

func _ready() -> void:
	if DEBUGGING:
		print("Running {n}._ready()... connected joypads: {j}".format({
			"n":name,
			"j": Input.get_connected_joypads()
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}' (Expect 'root')".format({
			"n":name,
			"p":get_parent().name,
			}))

	# Load the World scene
	var world_scene = preload("res://scenes/World.tscn")

	# Instantiate the World
	world = world_scene.instance()

	# Set number of players to number of joysticks
	world.num_players = Input.get_connected_joypads().size()

	# Make the world a child node of the Main scene
	add_child(world)

	# Connect to the signal that detects when a joystick connects
	var _ret: int # '_' in _var tells GDScript unused var is OK
	_ret = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	if _ret != 0:
		print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _ret}))

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if DEBUGGING:
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

		world.remove_player(device)
		print("Removed player index {d} from the world.".format({"d":device}))

	# HARDWARE TESTS:
	# 1. Two XBOX controllers: always PASS.
	# Expect when connecting/disconnecting joysticks the player
	# fades when disconnected and is restored when connected.
	# Run within Godot with F5: PASS
	# Run as exported .exe on Windows: PASS.
	#
	# 2. Two XBOX controllers and Steam controller: FAIL intermittently
	#
	# To use the Steam controller I need to launch the game from Steam.
	# Run as exported .exe on Windows, but launch from Steam (add
	# .exe as a non-Steam game to Steam library).
	#
	# Expect all players are connected when game starts.
	# Launch from Steam: PASS
	#
	# Expect when disconnecting joysticks the player fades.
	# Launch from Steam: PASS
	#
	# Expect when disconnecting/reconnecting joysticks the player
	# fades when disconnected and is restored when connected.
	# Launch from Steam: PASS sometimes
	# Observed behaviors on FAIL:
	# 1. Cycling the Steam controller steals control from an XBOX
	# controlled-player. The XBOX controller takes over what used
	# to be the Steam controller's player.
	#
	# 2. Sometimes the game does not recognize when a player
	# reconnects. But if a player is able to reconnect once,
	# reconnecting always works in that session for that player.
	# If reconnecting does not work for a player, it will not
	# work again for that joystick in that session.
	#
	# This behavior is not particular to any of the three
	# controllers.

