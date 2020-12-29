class_name Block
extends Node2D

# TODO: call update() in the setters.

var top_left: Vector2 setget set_top_left
var length: float setget set_length
var color: Color setget set_color

onready var grid: Grid = Grid.new()

func _ready():
	add_child(grid)
	self.length = grid.size

# _draw() runs once, sometime shortly after _ready() runs
func _draw() -> void:
	draw_square()


func set_top_left(xy: Vector2) -> void:
	top_left = xy
	# print("top_left: {val}".format({"val":top_left}))
	update()


func set_length(d: float) -> void:
	length = d


func set_color(c: Color) -> void:
	color = c


# Update position when the Player moves its block.
func move(direction: Vector2 ) -> void:
	self.top_left += direction * grid.size

# I wrote `draw_square`.
# I learned from the example here on "Custom drawing in 2D":
# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html

# Draw a square. Use units of pixels.
# Usage: Call `draw_square()` in `_draw()`.
# Example: draw_square(
#					Vector2(10.0, 10.0),
#					10.0,
#					ColorN("lightsalmon", 1),
#					)
func draw_square() -> void:
	# Define the vertices
	var points: PoolVector2Array = PoolVector2Array()
	assert(points.empty()) # no points yet
	points.append(self.top_left)
	var x:float = self.top_left.x
	var y:float = self.top_left.y
	points.append(Vector2(x,y+self.length))
	points.append(Vector2(x+self.length,y+self.length))
	points.append(Vector2(x+self.length,y))
	points.append(self.top_left)
	assert(not points.empty()) # got me some points

	# Call built-in polygon drawing command
	draw_colored_polygon(points, self.color)

