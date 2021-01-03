# USAGE: instantiate Grid to lookup Grid.size.
class_name Grid
extends Node

var DEBUGGING: bool
const SIZE: int = 20

# _ready() is never called!
# (because no one adds Grid as a Child Node)
#
# In case I ever do use Grid as a Node,
# here is a `_ready()` with my boiler-plate DEBUGGING inheritance.
func _ready() -> void:
	# Inherit parent.DEBUGGING if this scene is not the entry point.
	var parent_node: Node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING
	else:
		DEBUGGING = true
