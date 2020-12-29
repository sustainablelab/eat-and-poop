class_name Block
extends Node2D

# TODO: call update() in the setters.

var top_left: Vector2 setget set_top_left
var length: float setget set_length
var color: Color setget set_color

# length_is_grow: true -> animate growing, false -> animate shrinking
var length_is_grow: bool = true
# growth_shrink_amount sets how much to grow/shrink by: 0 == no growth
const GROW_SHRINK_AMOUNT: float = 0.1 # range: 0.0:1.0
# TODO: clamp GROW_SHRINK_AMOUNT to the range 0 to 1
var max_growth: float
var max_shrink: float

onready var grid: Grid = Grid.new()
onready var smooth_move: Tween = Tween.new()

func _ready():
	add_child(grid)
	self.length = grid.size
	max_growth = grid.size * (1 + GROW_SHRINK_AMOUNT)
	max_shrink = grid.size * (1 - GROW_SHRINK_AMOUNT)
	add_child(smooth_move)


# Animate the block.
# `delta` is time elapsed since `_process()` was last called.
# `delta` is fed to me from under the hood.
# `delta` is on the order of 10ms, the exact value depends on how
# busy the processor is.
func _process(delta):
	# Vary the square size
	# TODO: this is crude... do something better with Tween?
	# Or don't do this at all. Vary polygon coordinates instead.
	if length_is_grow:
		self.length += delta * max_growth
		if self.length >= max_growth:
			length_is_grow = not length_is_grow
	else:
		self.length -= delta * max_shrink
		if self.length <= max_shrink:
			length_is_grow = not length_is_grow


# _draw() runs once, sometime shortly after _ready() runs
func _draw() -> void:
	draw_square()


func set_top_left(xy: Vector2) -> void:
	top_left = xy
	# print("top_left: {val}".format({"val":top_left}))
	update()


func set_length(d: float) -> void:
	length = d
	update()


func set_color(c: Color) -> void:
	color = c
	update()

# Update position when the Player moves its block.
func move(direction: Vector2 ) -> void:
	# Choppy motion:
	#self.top_left += direction * grid.size
	# Smooth motion:
	smooth_move.interpolate_property(
		self, # object
		"top_left", # property name
		self.top_left, # start
		self.top_left + direction * grid.size, # stop
		0.1, # take 100 ms to move
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT,
		0) # delay
	smooth_move.start()


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

