extends Node


# I don't need to use the editor to add `Block` as a child node
# of `Player`. I do this in the code instead!

# Track whether the player is in the middle of a moving animation.
var is_moving: bool = false

# Create a player. Add node in `_ready()` with `add_child(player)`.
onready var player: Block = Block.new()

# Play with color in Godot editor.
# I can "force" this back to lightsalmon by editing Player.tscn.
export var color: Color = ColorN("lightsalmon", 1) # color, alpha


func _ready() -> void:
	add_child(player)
	# Player size is determined by Grid.size
	# Set player's starting position
	var x:float = 100.0
	var y:float = 100.0
	player.top_left = Vector2(x,y)
	# Set player's color (set in the editor: Player - Inspector)
	player.color = color
	# Detect tween start/stop to ignore inputs while moving.
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = player.smooth_move.connect("tween_started", self, "_on_smooth_move_started")
	_ret = player.smooth_move.connect("tween_completed", self, "_on_smooth_move_completed")

# ------------------------------------------------
# | Move player based on keyboard/joystick input |
# ------------------------------------------------

# Assign a direction to each arrow press.
var ui_inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left":  Vector2.LEFT,
	"ui_up":    Vector2.UP,
	"ui_down":  Vector2.DOWN,
	}

# Call one move per arrow press. Event based.
# One move per press is undesirable.
# TODO: difference between unhandled_input and input?
# func _input(event):
# func _unhandled_input(event):
# 	print(event.as_text())
# 	for arrow in ui_inputs.keys():
# 		if event.is_action_pressed(arrow):
# 			player.move(ui_inputs[arrow])

# Move while key is pressed. Polling based.
# Neat but undesirable affect that Tween does not start until release.
# func _process(_delta):
# 	for arrow in ui_inputs.keys():
# 		if Input.is_action_pressed(arrow):
# 			player.move(ui_inputs[arrow])


# Track when the movement tween animation is happening.
func _on_smooth_move_started(_object, _key): # _vars are unused
	self.is_moving = true

func _on_smooth_move_completed(_object, _key): # _vars are unused
	self.is_moving = false


func _process(_delta):
	# Ignore events while Tween animates player moving.
	if not is_moving:
		for arrow in ui_inputs.keys():
			if Input.is_action_pressed(arrow):
				player.move(ui_inputs[arrow])
