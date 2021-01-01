class_name HitBox
extends Area2D

# Instantiate a CollisionShape2D
onready var collision_area: CollisionShape2D = CollisionShape2D.new()
# Define the shape as a rectangle, width and height is twice
# half_extents.
# Hardcode a placeholder for Parent node to override.
var half_extents := Vector2(1.0, 1.0)

func _ready() -> void:
	add_child(collision_area)
	collision_area.shape = RectangleShape2D.new()
	collision_area.shape.extents = self.half_extents

	# SETUP COLLISIONS
	# Detect collisions.
	# var _ret: int
	# _ret = self.connect("area_entered", self, "_on_area_entered")


# func _on_area_entered(area):
# 	print("This Area entered me:")
# 	print(area)
