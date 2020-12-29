extends Node


# I don't need to use the editor to add `Block` as a child node
# of `Player`. I do this in the code instead!
# Create a player. Add node in `_ready()` with `add_child(player)`.
onready var player: Block = Block.new()

func _ready() -> void:
	add_child(player)
	# block.color = ColorN("lightsalmon", 1) # color, alpha
	# Set size with `set_size`
