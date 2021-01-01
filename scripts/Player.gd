extends Node2D # change to Spatial

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

# CHILD NODE: BLOCK
# I don't need to use the editor to add `Block` as a child node
# of `Player`. I do this in the code instead!
# Create a player as an instance of Block.
# GDScript compiler knows `Block` is a class because of `class_name` in `Block.gd` 
onready var player_block: Block = Block.new()
# Add `Block` as a child node in `_ready()` with `add_child(player_block)`.
onready var player_hitbox: HitBox = HitBox.new()
# Add `HitBox` as a child node in `_ready()` with `add_child(player_hitbox)`.


# COLOR
# Hardcode a color for testing.
# Parent overrides color when instantiating player.
# `export` color to play with color in the Godot editor.
# If exporting, the hardocoded color is set by Godot editor.
# Edit Player.tscn to set this default in code.
# export var color: Color = ColorN("lightsalmon", 1) # color, alpha
var color: Color = ColorN("magenta", 1) # color, alpha


func _ready() -> void:
	# Hardcode player's starting position for testing.
	self.position = Vector2(100.0,100.0)

	add_child(player_hitbox)
	player_hitbox.half_extents = Vector2(grid.size/2.0, grid.size/2.0)
	print(player_hitbox.half_extents)
	print(player_hitbox.collision_area.shape)

	add_child(player_block)
	# Player size is determined by Grid.size
	# Player starting position is determined by Parent.
	# Set player's color (set in the editor: Player - Inspector)
	player_block.color = color

	# SETUP MOVEMENT
	# Use a tween to animate moving in the grid.
	add_child(smooth_move)
	# Detect tween start/stop to change wobble effect while moving.
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = smooth_move.connect("tween_started", self, "_on_smooth_move_started")
	_ret = smooth_move.connect("tween_completed", self, "_on_smooth_move_completed")
	# TODO: decrease speed as the player gets bigger
	# self.speed = 0.1
	self.speed = grid.size / 200.0
	if self.speed > 0.1:
		self.speed = 0.1
	if self.speed < 0.05:
		self.speed = 0.05

	# SETUP COLLISIONS
	# Detect collisions.
	_ret = player_hitbox.connect("area_entered", self, "_on_area_entered")


# ------------------------------------------------------
# | Move player_block based on keyboard/joystick input |
# ------------------------------------------------------
func _process(_delta):
	# Ignore events while Tween animates player_block moving.
	if not is_moving:
		for motion in ui_inputs: # `for` iterates over dict keys
			if Input.is_action_pressed(motion):
				# player_block.move(ui_inputs[motion])
				self.move(ui_inputs[motion])
				# DEBUGGING
				# print(Input.get_joy_name(self.device_num))
				# print(Input.get_joy_axis(self.device_num, 0))

# Update position when the Player moves its block.
var speed: float

func move(direction: Vector2 ) -> void:
	# Move one tile. Basically do this:
	# self.position += direction * grid.size
	# But use a Tween for animating motion between tiles.

	# _done is true when Tween.blah() is done.
	# I store return values in "_vars" to avoid Debugger warnings.

	var _done: bool
	_done = smooth_move.interpolate_property(
		self, # object
		"position", # property name
		self.position, # start
		self.position + direction * grid.size, # stop
		self.speed, # time it takes to move in seconds
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
	self.is_moving = true
	self.player_block.express_motion()

	# DEBUGGING
	# print("tween start:")
	# print("\tplayer_block.top_left = {v}".format({"v":player_block.top_left}))
	# print("\tself.position = {v}".format({"v":self.position}))


func _on_smooth_move_completed(_object, _key): # _vars are unused
	self.is_moving = false
	self.player_block.express_standing_still()

	# DEBUGGING
	# print("tween stop:")
	# print("\tplayer_block.top_left = {v}".format({"v":player_block.top_left}))
	# print("\tself.position = {v}".format({"v":self.position}))


func _on_area_entered(area):
	print("{a} entered by {b}:".format({"a":self.player_hitbox, "b":area}))
