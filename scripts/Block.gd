class_name Block
extends Node2D

# The fundamental square parameters use setters.
# The setters call update(): anytime these fundamental square
# parameters are written, update() redraws the square.
var top_left: Vector2 setget set_top_left
var length: float setget set_length
var color: Color setget set_color
var square_points: PoolVector2Array setget set_square_points

# Randomize the square points for a wobble effect.
var square_wobbles: bool = true
# Time it takes to move in seconds
# TODO: decrease speed as the player gets bigger
# var speed: float = 0.2 # bigger number = slower
var speed: float
# self.speed = grid.size / 200.0
var wobble_period: float = 0.01 # bigger number = slower

# growth_shrink_amount sets how much to grow/shrink by: 0 == no growth
# range: 0.0:1.0
# const GROW_SHRINK_AMOUNT: float = 0.02
var GROW_SHRINK_AMOUNT: float
# Increase amount while moving to communicate player is active.
# const GROW_SHRINK_AMOUNT_WHILE_MOVING: float = 0.05
var GROW_SHRINK_AMOUNT_WHILE_MOVING: float

# TIP:
# Slower wobbles look more like an object in motion.
# Faster wobbles look more like blur and shimmer.
# Slower wobbles look better as smaller wobbles.
# Faster wobbles can get away with larger wobbles.

# var max_growth: float
# var max_shrink: float
var max_deviation: float
# Grow/Shrink by a random amount
var rng = RandomNumberGenerator.new()

onready var grid: Grid = Grid.new()
onready var smooth_move: Tween = Tween.new()

func _ready():
	add_child(grid)
	# Player starts as a normal square shape.
	self.length = grid.size
	self.square_points = normal_square()
	# Dividing by grid.size exaggerates wobbles for smaller grids
	# which is good for overcoming truncation to pixel number.
	GROW_SHRINK_AMOUNT = 0.5 / grid.size
	# GROW_SHRINK_AMOUNT = 4.0 / grid.size
	GROW_SHRINK_AMOUNT_WHILE_MOVING = GROW_SHRINK_AMOUNT * 3.0
	# max_growth = grid.size * (1 + GROW_SHRINK_AMOUNT)
	# max_shrink = grid.size * (1 - GROW_SHRINK_AMOUNT)
	# Player's shape deviates with a wobbly effecet.
	max_deviation = grid.size * GROW_SHRINK_AMOUNT
	# Seed a random number generator for wobbling.
	rng.randomize() # setup the generator from a time-based seed
	# Use a tween to animate moving in the grid.
	add_child(smooth_move)
	# Detect tween start/stop to change wobble effect while moving.
	# (`connect()` returns 0: throw away return value in a '_var')
	var _ret: int
	_ret = smooth_move.connect("tween_started", self, "_on_smooth_move_started")
	_ret = smooth_move.connect("tween_completed", self, "_on_smooth_move_completed")
	# TODO: decrease speed as the player gets bigger
	# self.speed = 0.1
	self.speed = grid.size / 200.0
	if self.speed > 0.1:
		self.speed = 0.1
	if self.speed < 0.05:
		self.speed = 0.05

# Animate the wobble effect.
# Use `delta_sum` to detect when a wobble period elapses.
# TODO: maybe replace this solution with a timer-based? Any
# noticeable difference?
# https://docs.godotengine.org/en/stable/getting_started/workflow/best_practices/godot_notifications.html
var delta_sum: float = 0
# `delta` is time elapsed since `_process()` was last called.
# `delta` is fed to me from under the hood.
# `delta` is on the order of 10ms, the exact value depends on how
# busy the processor is.
# Animate the wobble effect.
func _process(delta):
	if square_wobbles:
		delta_sum += delta
		if delta_sum >= self.wobble_period:
			self.square_points = random_wobbly_square()
			# update() # update the _draw() stuff
			# Reset the wobble period timer
			delta_sum = 0

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


func set_square_points(p: PoolVector2Array) -> void:
	square_points = p
	update()


func set_color(c: Color) -> void:
	color = c
	update()

# Update position when the Player moves its block.
func move(direction: Vector2 ) -> void:
	# Choppy motion without Tween:
	#self.top_left += direction * grid.size

	# Smooth motion with Tween:

	# _done is true when Tween.blah() is done.
	# I store return values in "_vars" to avoid Debugger warnings.
	var _done: bool
	_done = smooth_move.interpolate_property(
		self, # object
		"top_left", # property name
		self.top_left, # start
		self.top_left + direction * grid.size, # stop
		self.speed, # time it takes to move in seconds
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT,
		0) # delay

	_done = smooth_move.start()


# Use a larger deviation in draw_square points to emphasize movement
func _on_smooth_move_started(_object, _key): # _vars are unused
	self.max_deviation = grid.size * GROW_SHRINK_AMOUNT_WHILE_MOVING


# Restore deviation to original amount
func _on_smooth_move_completed(_object, _key): # _vars are unused
	self.max_deviation = grid.size * GROW_SHRINK_AMOUNT


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

# Generate the points for a normal square.
func normal_square() -> PoolVector2Array:
	# Define the vertices
	var points: PoolVector2Array = PoolVector2Array()
	assert(points.empty()) # no points yet
	var x:float = self.top_left.x
	var y:float = self.top_left.y
	points.append(Vector2(x,y))
	points.append(Vector2(x,y+self.length))
	points.append(Vector2(x+self.length,y+self.length))
	points.append(Vector2(x+self.length,y))
	assert(not points.empty()) # got me some points
	return points

# Generate the points for a wobbly square.
func random_wobbly_square() -> PoolVector2Array:
	# Define the vertices.
	# Start with an empty list of points.
	var points: PoolVector2Array = PoolVector2Array()
	var x:float = self.top_left.x
	var y:float = self.top_left.y
	var random: float
	# Randomize to a range?
	# var random_amount = rng.randf_range(max_shrink, max_growth)
	# Or randomize to a Gaussian distribution?
	# random = rng.randfn( # normally-distributed
	# 		0.0, # mean
	# 		max_deviation # deviation
	# 		)
	# To make the square shake, use the same random number for
	# all points.
	# To make the square wobble, generate a new random number for
	# each point.
	random = rng.randfn(0.0, max_deviation)
	points.append(Vector2(x+random,y+random))
	random = rng.randfn(0.0, max_deviation)
	points.append(Vector2(x+random,y+random+self.length))
	random = rng.randfn(0.0, max_deviation)
	points.append(Vector2(x+random+self.length,y+random+self.length))
	random = rng.randfn(0.0, max_deviation)
	points.append(Vector2(x+random+self.length,y+random))
	return points

func draw_square() -> void:
	# Call built-in polygon drawing command
	# Use whatever the current values of square_points and color are.
	# `square_points` is set to a "normal_square" onready.
	# If the `square_wobbles`, `square_points` is updated each
	# `wobble_period`.
	draw_colored_polygon(self.square_points, self.color)

