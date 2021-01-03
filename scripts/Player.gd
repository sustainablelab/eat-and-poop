# Player
# ├─ Tween (Godot built-in for motion)
# ├─ RayCast2D (Godot built-in for detecting if tiles are empty)
# ├─ Grid (Grid.gd -- set Grid size)
# ├─ HitBox (HitBox.gd -- define a collision area)
# └─ Block (Block.gd -- what Player looks like on the screen)
#
# ADD CHILD NODES
# I don't use the Godot editor to add Child nodes to `Player`.
# I do this in the code instead.
# See the docs for "creating nodes":
# https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_continued.html?highlight=_ready#creating-nodes
# There are two steps:
# 1. Define Player property as instance of Child node class with `new()`
# 2. Call add_child() in _ready().
# CHILD NODE CLASSES
# For classes I define in `.gd` scripts, the GDScript compiler knows about the
# class because of the script's first line: `class_name`.
# USE PLAYER
# Player has no class_name because Player is a scene!
# Assign Player.gd (this script) to scene Player.tscn in Godot editor.
# The Parent makes Player a Child node in code.
# See the docs for "instancing scenes":
# https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_continued.html?highlight=_ready#instancing-scenes
#
# Three steps:
# 1. Load the Player scene:
#	const player_scene = preload("res://scenes/Player.tscn")
# 2. Instantiate a player: (like the .new() in the previous)
#	var player1 = player_scene.instance()
# 3. Add as a child node:
#	add_child(player1)
#
# Player is a scene, not just a script with a class name.
# Scenes have execution benefits under the hood.
# And as a scene, it is a stand-alone game component I can test with `F6`.

extends Node2D

# TODO: detect collisions with other players

# TODO: time standing still, tell `player_block` to `express_pooping()` when
# timer is up, similar idea to `express_motion`.
#
# JOYSTICK
# Hardcode a default joystick device_num for testing.
# Parent overrides `device_num` when it instantiates Player and
# add it as a child node.
var device_num: int = 0 # default to device 0

# MOVEMENT
onready var grid: Grid = Grid.new()
onready var smooth_move: Tween = Tween.new()
# Ignore joystick motions while movement animation is underway.
var is_moving: bool = false # true when player_block is moving between tiles

onready var player_block: Block = Block.new() # see add_child(player_block)
onready var player_hitbox: HitBox = HitBox.new() # see add_child(player_hitbox)
onready var player_ray: RayCast2D = RayCast2D.new() # see add_child(player_ray)

# NAME
# Hardcode a name for testing.
# Parent overrides name when instantiating player.
var player_name: String = "player_name"

# COLOR
# Hardcode a color for testing.
# Parent overrides color when instantiating player.
# `export` color to play with color in the Godot editor.
# If exporting, the hardocoded color is set by Godot editor.
# Edit Player.tscn to set this default in code.
# export var color: Color = ColorN("lightsalmon", 1) # color, alpha
var color: Color = ColorN("magenta", 1) # color, alpha

# Hardcode player's starting position for testing.
var start_position: Vector2 = Vector2(100.0, 100.0)

func _ready() -> void:
	print("Running Player._ready()...")
	# Use starting position set by Parent Node.
	# This uses the default start_position when testing Player.
	position = start_position

	# Setup the HitBox: override HitBox size (half_extents)
	# player_hitbox.half_extents = Vector2(grid.size/1.5, grid.size/1.5)
	player_hitbox.half_extents = Vector2(grid.size/2.5, grid.size/2.5)
	player_hitbox.area_name = player_name
	add_child(player_hitbox)
	print("hitbox half_extents: {h}".format({"h":player_hitbox.half_extents}))

	# Setup RayCast2D
	# Enable Area2D detection. Defaults to False.
	player_ray.collide_with_areas = true
	# Ignore colliding with Player's own Area2D!
	player_ray.add_exception(player_hitbox)
	# Enable ray cast? This seems to make no difference.
	# player_ray.enabled = true
	# player_ray.enabled = false # default
	add_child(player_ray)

	# Player size is determined by Grid.size
	# Player starting position and color is determined by Parent.
	# Why do I code color here and not position?
	# Position is a property of Player.
	# For testing, I default to 0,0.
	# But color is a property of Player Child Node: Block.
	# And I don't want Parent of Player to know that Block exists.
	# So Player passes its color property to whichever children need to know
	# about color.
	player_block.color = color
	add_child(player_block)

	# SETUP MOVEMENT
	# Use a tween to animate moving in the grid.
	add_child(smooth_move)
	# Detect tween start/stop to change wobble effect while moving.
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = smooth_move.connect("tween_started", self, "_on_smooth_move_started")
	_ret = smooth_move.connect("tween_completed", self, "_on_smooth_move_completed")
	# TODO: decrease speed as the player gets bigger
	# speed = 0.1
	speed = grid.size / 200.0
	if speed > 0.1:
		speed = 0.1
	if speed < 0.05:
		speed = 0.05

	# SETUP COLLISIONS
	# Detect collisions.
	_ret = player_hitbox.connect("area_entered", self, "_on_area_entered")


# ---------------------
# | Move player_block |
# ---------------------
func _process(_delta):
	# Ignore events while Tween animates player_block moving.
	if not is_moving:
		# Move based on keyboard/joystick input
		for motion in ui_inputs: # `for` iterates over dict keys
			if Input.is_action_pressed(motion):
				# player_block.move(ui_inputs[motion])
				move(ui_inputs[motion])
				# DEBUGGING
				# print(Input.get_joy_name(self.device_num))
				# print(Input.get_joy_axis(self.device_num, 0))


# Update position when the Player moves its block.
var speed: float


func move(direction: Vector2 ) -> void:
	# Ray cast to test for collision before moving
	var relative_movement = (direction * grid.size)
	var destination = position + relative_movement
	player_ray.cast_to = relative_movement
	player_ray.force_raycast_update()
	if player_ray.is_colliding():
		# Some values I might want to use later.
		# var collision_point: Vector2 = player_ray.get_collision_point()
		# var collision_normal: Vector2 = player_ray.get_collision_normal()
		# var collider_name: String = player_ray.get_collider().area_name
		# var collider_size: Vector2 = player_ray.get_collider().half_extents*2

		# Do a motion tween, but don't go anywhere.
		destination = position

	# At this point, the player is still going to show an "attempt" to move. If
	# there was a collision, the player will not move anywhere. If not, the
	# player will move there.

	# Move one tile. Basically do this:
	# position += direction * grid.size
	# But use a Tween for animating motion between tiles.

	# _done is true when Tween.blah() is done.
	# I store return values in "_vars" to avoid Debugger warnings.

	var _done: bool
	_done = smooth_move.interpolate_property(
		self, # object
		"position", # property name
		position, # start
		destination, # stop
		speed, # time it takes to move in seconds
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT,
		0) # delay

	_done = smooth_move.start()


# Assign a direction to each arrow press.
# Actual InputMap is defined by Parent.
# Hardcode a mapping for testing.
var ui_inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left":  Vector2.LEFT,
	"ui_up":    Vector2.UP,
	"ui_down":  Vector2.DOWN,
	}


# Track when the movement tween animation is happening.
func _on_smooth_move_started(_object, _key): # _vars are unused
	is_moving = true
	player_block.express_motion()

	# DEBUGGING
	# print("tween start:")


func _on_smooth_move_completed(_object, _key): # _vars are unused
	is_moving = false
	player_block.express_standing_still()

	# DEBUGGING
	# print("tween stop:")


func _on_area_entered(area):
	# TODO: Get thrown back if standing still.
	if not is_moving:
		# Use get_collision_normal to find out the Vector2 of the attacker.
		# Placeholder: always move right
		self.move(Vector2.RIGHT)
		pass

	# Only print a message for the player that caused the collision.
	# DEBUGGING
	print("{a} entered by {b}.".format({"a":player_hitbox.area_name, "b":area.area_name}))
	# Example:
	# lightseagreen player moves into square occupied by magenta
	#
	#	magenta entered by lightseagreen.
	#	lightseagreen entered by magenta.
	#
	# If magenta entered lightseagreen's square, the order flips:
	#
	#	lightseagreen entered by magenta.
	#	magenta entered by lightseagreen.
	#
