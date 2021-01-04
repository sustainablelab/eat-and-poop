# Player
# ├─ Tween (Godot built-in for motion)
# ├─ RayCast2D (Godot built-in for detecting if tiles are empty)
# ├─ Grid (Grid.gd -- set Grid size)
# ├─ HitBox (HitBox.gd -- define a collision area)
# └─ Block (Block.gd -- what Player looks like on the screen)
#
extends Node2D

var DEBUGGING: bool

# TODO: time standing still, tell `player_block` to `express_pooping()` when
# timer is up, similar idea to `express_motion`.

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

# Find out how big my world is.
var world: Rect2

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
	# Inherit parent.DEBUGGING if this scene is not the entry point.
	var parent_node: Node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING
	else:
		DEBUGGING = true

	if DEBUGGING:
		print("Running Player.gd: {n}._ready()... {pn}".format({
			"n": name,
			"pn": player_name,
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
			}))

	# Use starting position set by Parent Node.
	# This uses the default start_position when testing Player.
	position = start_position

	# Setup the HitBox: override HitBox size (half_extents)
	# player_hitbox.half_extents = Vector2(grid.SIZE/1.5, grid.SIZE/1.5)
	# player_hitbox.half_extents = Vector2(grid.SIZE/2.5, grid.SIZE/2.5)
	player_hitbox.half_extents = Vector2(grid.SIZE/2.0, grid.SIZE/2.0)
	player_hitbox.area_name = player_name
	add_child(player_hitbox)

	# SETUP COLLISION DETECTION
	# Setup RayCast2D for COLLISIONS
	# Enable Area2D detection. Defaults to False.
	player_ray.collide_with_areas = true
	# Ignore colliding with Player's own Area2D!
	player_ray.add_exception(player_hitbox)
	# Enable ray cast? This seems to make no difference.
	# player_ray.enabled = true
	# player_ray.enabled = false # default
	add_child(player_ray)

	# Player size is determined by Grid.SIZE
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
	var _ret: int
	_ret = smooth_move.connect("tween_started", self, "_on_smooth_move_started")
	_ret = smooth_move.connect("tween_completed", self, "_on_smooth_move_completed")
	# SETUP COLLISIONS
	# Detect collisions.
	_ret = player_hitbox.connect("area_entered", self, "_on_area_entered")
	_ret = parent_node.connect("player_hit", self, "_on_player_hit")

	# Find out how big my world is.
	world = parent_node.game_window

# ---------------------
# | Move player_block |
# ---------------------
var DEBUGGING_JOYMOTION := false
func _process(_delta):
	# Ignore events while Tween animates player_block moving.
	if not is_moving:
		# Move based on keyboard/joystick input
		for motion in ui_inputs: # `for` iterates over dict keys
			if Input.is_action_pressed(motion):
				# player_block.move(ui_inputs[motion])
				move(ui_inputs[motion])
				if DEBUGGING_JOYMOTION:
					print(Input.get_joy_name(self.device_num))
					print(Input.get_joy_axis(self.device_num, 0))


# Emit a signal when this Player's move causes a collision.
signal hit


# Respond to `hit` signal when another Player's move collided into this player.
func _on_player_hit(victim_name, collision_normal) -> void:
	if victim_name == player_name:
		# This player is the victim. Respond.
		if DEBUGGING:
			print("{pn} was hit!".format({
				"pn": player_name,
				}))
		# move_because_hit(collision_normal*-1)
		move(collision_normal*-1, speed_from_being_hit())


var DEBUGGING_COLLISION := false


func move_will_collide(ray: RayCast2D, relative_movement: Vector2) -> bool:
	ray.cast_to = relative_movement
	ray.force_raycast_update()
	var will_collide: bool = ray.is_colliding()
	# Handle Corner Case:
	# Two players charge at each other.
	# If players start movement at exact same time, they both get onto the same
	# square, then they're frozen because of colliding.
	# Temporary fix: detect this case and let players pass through each other.
	var TEMPORARY_FIX := true
	if TEMPORARY_FIX:
		if ray.get_collision_normal() == Vector2(0,0):
			# if the normal is 0,0, collision happens while players are on the
			# same square.
			will_collide = false

	# LONGTERM FIX:
	# Kurt says either:
	# 1. Actually fix it so this case never happens.
	# 2. When throw-back behavior is implemented, make it so that game
	# randomly decides which player "won" that confrontation, and the other
	# player gets thrown back.

	return will_collide

func notify_victim(ray: RayCast2D) -> void:
	# Emit a signal connected to World.
	# World then broadcasts a new signal connected to all players.
	#
	# Some values I might want to use later:
	# var collision_point: Vector2 = player_ray.get_collision_point()
	# var collider_size: Vector2 = player_ray.get_collider().half_extents*2

	var victim_name: String = ray.get_collider().area_name
	var collision_normal: Vector2 = ray.get_collision_normal()
	# Notify other player with collision details.
	emit_signal("hit", victim_name, collision_normal)

	if DEBUGGING_COLLISION:
		print("collision_normal: {n}".format({"n": collision_normal}))
		print("victim_name: {n}".format({"n": victim_name}))



# # Update position when the Player is moved after being hit.
# func move_because_hit(direction: Vector2) -> void:
# 	# Calculate relative and absolute destination.
# 	# Relative is for RayCast. Absolute is for Tween.
# 	var relative_movement = (direction * grid.SIZE)
# 	var destination = position + relative_movement
# 	# Test for collision.
# 	if move_will_colide(relative_movement):

func speed_from_regular_movement() -> float:
	# Return Tween speed for regular movement.
	# TODO: use modifier key Shift for speedup
	# var speed = grid.SIZE / 200.0
	# if speed > 0.1:
	# 	speed = 0.1
	# if speed < 0.05:
	# 	speed = 0.05
	var speed: float = 0.2
	return speed


func speed_from_hitting() -> float:
	var speed: float = 1.2*speed_from_regular_movement()
	return speed


func speed_from_being_hit() -> float:
	var speed: float = 0.7*speed_from_regular_movement()
	return speed

# Update position when the Player moves its block.
func move(direction: Vector2, speed: float = speed_from_regular_movement()) -> void:
	# Calculate relative and absolute destination.
	var relative_movement = (direction * grid.SIZE) # for RayCast
	var destination = position + relative_movement # for Tween

	if DEBUGGING:
		print("Me before: {m}, after: {a}, World Bounds: {wp}-{we}".format({
			"m": position.x,
			"a": destination.x,
			"wp": world.position.x,
			"we": world.end.x,
			}))

	# TODO: this screen wrapping has problems:
	# 1. Player zips across screen instead of wrapping.
	# 2. RayCast does not see the player it hits by wrapping.
	#
	# Wrap around the screen. "position" is top-left, "end" is bottom-right
	if destination.x < world.position.x:
		destination.x = world.end.x
	elif destination.x > world.end.x:
		destination.x = world.position.x
	if destination.y < world.position.y:
		destination.y = world.end.y
	elif destination.y > world.end.y:
		destination.y = world.position.y

	if move_will_collide(player_ray, relative_movement):
		notify_victim(player_ray)
		# Slow the attacker
		if speed == speed_from_regular_movement():
			speed = speed_from_hitting()

	# Use a Tween for animating motion between tiles.

	# TODO: Mess with other Tween easing functions.
	# Maybe easing functions are better than varying movement speed for making
	# it feel like the victim is suddenly pushed (start quick, then ease out
	# with overshoot), or the attacker needed to gather force (start slow, then
	# burst at the end).

	# Compiler ignores unused vars with `_` prefix
	var _done: bool # Always True.
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
var DEBUGGING_TWEEN := false
func _on_smooth_move_started(_object, _key): # _vars are unused
	is_moving = true
	player_block.express_motion()

	if DEBUGGING_TWEEN:
		print("tween start:")


func _on_smooth_move_completed(_object, _key): # _vars are unused
	is_moving = false
	player_block.express_standing_still()

	if DEBUGGING_TWEEN:
		print("tween stop:")


func _on_area_entered(area):
	# TODO: Get thrown back if standing still.
	if not is_moving:
		# Use get_collision_normal to find out the Vector2 of the attacker.
		# Placeholder: always move right
		# self.move(Vector2.RIGHT)
		print("{a} was not moving.".format({"a":player_hitbox.area_name}))
	else:
		print("{a} was moving.".format({"a":player_hitbox.area_name}))

	if DEBUGGING:
		print("{a} entered by {b} with collision_normal {n}.".format({
			"a":player_hitbox.area_name,
			"b":area.area_name,
			"n": player_ray.get_collision_normal()
			}))
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
