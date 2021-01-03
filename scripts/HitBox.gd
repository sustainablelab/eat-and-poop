# HitBox defines a collision area for the Parent node.
#
# USAGE:
# Instantiate in Parent node so that HitBox moves with Parent:
#	onready var player_hitbox: HitBox = HitBox.new()
# And remember to add as a Child node in Parent._ready:
#	add_child(player_hitbox)
# Also remember to override HitBox property `half_extents` BEFORE calling
# add_child(player_hitbox).
# Parent connects `area_entered` signal to a func that
# receives the intruding Area2D as a parameter.
# (Signal parameters are passed under the hood).
class_name HitBox
extends Area2D

# Hardcode a placeholder name for the Parent to override.
# Example: if Parent is a Player, Parent overrides with the player's color.
var area_name: String = "placeholder_name"

# Instantiate a CollisionShape2D
onready var collision_area: CollisionShape2D = CollisionShape2D.new()
# Define the shape as a rectangle, width and height is twice
# half_extents.
# Hardcode a placeholder for Parent node to override.
var half_extents := Vector2(1.0, 1.0)

func _ready() -> void:
	# DEBUGGING
	print("Running HitBox._ready()...")
	# Setup the collision_area:
	collision_area.shape = RectangleShape2D.new()
	collision_area.shape.extents = half_extents
	print("Hitbox _ready says half_extents are: {v}".format({"v":half_extents}))
	# Add the collision_area as a child_node.
	add_child(collision_area)

	# SETUP COLLISIONS
	# Detect collisions.
	# var _ret: int
	# _ret = self.connect("area_entered", self, "_on_area_entered")


# func _on_area_entered(area):
# 	print("This Area entered me:")
# 	print(area)

