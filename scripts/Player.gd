extends Node


# I don't need to use the editor to add `Block` as a child node
# of `Player`. I do this in the code instead!
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

# ---------------------------------------
# | Move player based on keyboard input |
# ---------------------------------------

# Assign a direction to each arrow press.
var ui_inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left":  Vector2.LEFT,
	"ui_up":    Vector2.UP,
	"ui_down":  Vector2.DOWN,
	}

# Call one move per arrow press.
func _unhandled_input(event):
	for arrow in ui_inputs.keys():
		if event.is_action_pressed(arrow):
			player.move(ui_inputs[arrow])

