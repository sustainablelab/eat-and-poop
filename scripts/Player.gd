extends Node2D # change to Spatial
# TODO: use Spatial translation() instead of hard-coded `top_left` coordinates

# Hardcode a default joystick device_num for testing.
# Parent overrides `device_num` when it instantiates Player and
# add it as a child node.
var device_num: int = 0 # default to device 0

# I don't need to use the editor to add `Block` as a child node
# of `Player`. I do this in the code instead!

var is_moving: bool = false # true when player_block is moving between tiles

# Create a player as an instance of Block.
# Add node in `_ready()` with `add_child(player_block)`.
onready var player_block: Block = Block.new()

# Play with color in Godot editor.
# I can "force" this back to lightsalmon by editing Player.tscn.
# export var color: Color = ColorN("lightsalmon", 1) # color, alpha
var color: Color = ColorN("lightsalmon", 1) # color, alpha


func _ready() -> void:
	add_child(player_block)
	# Player size is determined by Grid.size
	# Player starting position is determined by Parent.
	# Hardcode player's starting position for testing.
	var x:float = 100.0
	var y:float = 100.0
	player_block.top_left = Vector2(x,y)
	# Set player's color (set in the editor: Player - Inspector)
	player_block.color = color
	# Detect tween start/stop to ignore inputs while moving.
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = player_block.smooth_move.connect("tween_started", self, "_on_smooth_move_started")
	_ret = player_block.smooth_move.connect("tween_completed", self, "_on_smooth_move_completed")


# ------------------------------------------------------
# | Move player_block based on keyboard/joystick input |
# ------------------------------------------------------
func _process(_delta):
	# Ignore events while Tween animates player_block moving.
	if not is_moving:
		for motion in ui_inputs: # `for` iterates over dict keys
			if Input.is_action_pressed(motion):
				player_block.move(ui_inputs[motion])
				# DEBUGGING
				# print(Input.get_joy_name(self.device_num))
				# print(Input.get_joy_axis(self.device_num, 0))

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


func _on_smooth_move_completed(_object, _key): # _vars are unused
	self.is_moving = false
