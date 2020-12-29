class_name Block
extends Node2D

# TODO: create setget for Block variables so that I can call
# update() in the setters.

func _draw() -> void:
	var x:float = 100.0
	var y:float = 100.0
	var top_left: Vector2 = Vector2(x,y)
	var length:float = 10.0
	var color: Color = ColorN("lightsalmon", 1) # color, alpha
	draw_square(top_left, length, color)


# Custom drawing in 2D:
# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html

# Draw a square. Use units of pixels.
# Usage: Call `draw_square()` in `_draw()`.
# Example: draw_square(
#					Vector2(10.0, 10.0),
#					10.0,
#					ColorN("lightsalmon", 1),
#					)
func draw_square(top_left: Vector2, length: float, color: Color) -> void:
	# Define the vertices
	var points: PoolVector2Array = PoolVector2Array()
	assert(points.empty())
	points.append(top_left)
	var x:float = top_left.x
	var y:float = top_left.y
	points.append(Vector2(x,y+length))
	points.append(Vector2(x+length,y+length))
	points.append(Vector2(x+length,y))
	points.append(top_left)
	assert(not points.empty())

	# Call built-in polygon drawing command
	draw_colored_polygon(points, color)

