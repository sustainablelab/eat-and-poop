class_name Block
extends Node2D

# TODO: add hook for Parent to tell Block to `express_pooping()`,
# similar idea to `express_motion()`

# The fundamental square parameters use setters.
# The setters call update(): anytime these fundamental square
# parameters are written, update() redraws the square.
var top_left: Vector2 setget set_top_left
var length: float setget set_length
var color: Color setget set_color
var square_points: PoolVector2Array setget set_square_points

# Randomize the square points for a wobble effect.
var square_wobbles: bool = true
var wobble_period: float = 0.01 # bigger number = slower

# growth_shrink_amount sets how much to grow/shrink by: 0 == no growth
# range: 0.0:1.0
# const WOBBLE_AMOUNT: float = 0.02
var WOBBLE_AMOUNT: float
var SHAKE_AMOUNT: float
# Increase amount while moving to communicate player is active.
# const WOBBLE_AMOUNT_WHILE_MOVING: float = 0.05
var WOBBLE_AMOUNT_WHILE_MOVING: float

# TIP:
# Slower wobbles look more like an object in motion.
# Faster wobbles look more like blur and shimmer.
# Slower wobbles look better as smaller wobbles.
# Faster wobbles can get away with larger wobbles.

var max_wobble_deviation: float
var max_shake_deviation: float
# Grow/Shrink by a random amount
var rng = RandomNumberGenerator.new()

onready var grid: Grid = Grid.new()

func _ready():
	# DEBUGGING
	print("Running Block._ready()...")

	# Player starts as a normal square shape.
	# Player size matches grid tile size.
	length = grid.size
	# Center player artwork about player's position.
	top_left -= Vector2(length/2.0, length/2.0)
	self.square_points = normal_square()
	# Dividing by grid.size exaggerates wobbles for smaller grids
	# which is good for overcoming truncation to pixel number.
	WOBBLE_AMOUNT = 0.5 / grid.size
	# WOBBLE_AMOUNT = 4.0 / grid.size
	SHAKE_AMOUNT = 1.0 / grid.size
	WOBBLE_AMOUNT_WHILE_MOVING = WOBBLE_AMOUNT * 3.0
	# Player's shape deviates with a wobbly effecet.
	max_wobble_deviation = grid.size * WOBBLE_AMOUNT
	# Player's shape deviates with a shaky effecet.
	max_shake_deviation = grid.size * SHAKE_AMOUNT
	# Seed a random number generator for wobbling.
	rng.randomize() # setup the generator from a time-based seed

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
			# self.square_points = random_shaky_square()
			self.square_points = random_wobbly_square()
			# Reset the wobble period timer
			delta_sum = 0

# _draw() runs once, sometime shortly after _ready() runs
func _draw() -> void:
	draw_square()


func set_square_points(p: PoolVector2Array) -> void:
	# This is the important property.
	# I write this one all the time.
	# Then this triggers the redraw with its `update()`.
	square_points = p
	update()


func set_top_left(xy: Vector2) -> void:
	# So far I never write top_left with this setter.
	# It sits at it's starting position all game long.
	# The block moves around the screen because of the Parent
	# node's position.
	#
	# But I'm leaving this here for future effects.
	# 1) Visually shift the player off the tile grid
	# without affecting the `position` of Sibling nodes.
	# 2) Use with `self.length` for shrinking/growing.
	top_left = xy
	update()


func set_length(d: float) -> void:
	# Like top_left, I never write length with this setter.
	# `length` is `grid.size` all game long.
	# But I'm leaving this here for future effects.
	# 1) Use with `self.top_left` for shrinking/growing.
	length = d
	update()


func set_color(c: Color) -> void:
	color = c
	update()


# Larger deviation communicates block is in motion.
func express_motion():
	self.max_wobble_deviation = grid.size * WOBBLE_AMOUNT_WHILE_MOVING


# Restore deviation to original amount when standing still.
func express_standing_still():
	self.max_wobble_deviation = grid.size * WOBBLE_AMOUNT


# All cool art/animation is custom drawing in 2D -- see example
# here on "Custom drawing in 2D":
# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html


# Usage: Call `draw_square()` in `_draw()`.
func draw_square() -> void:
	# Call built-in polygon drawing command
	# Use whatever the current values of square_points and color are.
	# `square_points` is set to a "normal_square" onready.
	# If the `square_wobbles`, `square_points` is updated each
	# `wobble_period`.
	draw_colored_polygon(self.square_points, self.color)


# What animation is the square doing?
# This is determined by square_points.
# No animation, just a square:
#	self.square_points = normal_square()
# Wobbly square:
#	self.square_points = random_wobbly_square()
# Shaky square:
#	self.square_points = random_shaky_square()
# TODO: figure out how to setup animations for composability.
# Serially assigning square_points does not work.
# For example, this makes the square shake only:
#	self.square_points = random_wobbly_square()
#	self.square_points = random_shaky_square()

# Generate the vertices for a normal square.
# Use units of pixels.
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


func random_shaky_square() -> PoolVector2Array:
	# Define the vertices.
	# Start with an empty list of points.
	var points: PoolVector2Array = PoolVector2Array()
	var x:float = self.top_left.x
	var y:float = self.top_left.y
	var random: float
	# Randomize vertex position with a Gaussian distribution.
	# random = rng.randfn( # normally-distributed
	# 		0.0, # mean
	# 		max_shake_deviation # deviation
	# 		)
	# SHAKE: use the same random number for all points.
	random = rng.randfn(0.0, max_shake_deviation)
	points.append(Vector2(x+random,y+random))
	points.append(Vector2(x+random,y+random+self.length))
	points.append(Vector2(x+random+self.length,y+random+self.length))
	points.append(Vector2(x+random+self.length,y+random))
	return points


# Generate the points for a wobbly square.
func random_wobbly_square() -> PoolVector2Array:
	# Define the vertices.
	# Start with an empty list of points.
	var points: PoolVector2Array = PoolVector2Array()
	var x:float = self.top_left.x
	var y:float = self.top_left.y
	var random: float
	# Randomize vertex position with a Gaussian distribution.
	# random = rng.randfn( # normally-distributed
	# 		0.0, # mean
	# 		max_wobble_deviation # deviation
	# 		)
	# WOBBLE: generate a new random number for each point.
	random = rng.randfn(0.0, max_wobble_deviation)
	points.append(Vector2(x+random,y+random))
	random = rng.randfn(0.0, max_wobble_deviation)
	points.append(Vector2(x+random,y+random+self.length))
	random = rng.randfn(0.0, max_wobble_deviation)
	points.append(Vector2(x+random+self.length,y+random+self.length))
	random = rng.randfn(0.0, max_wobble_deviation)
	points.append(Vector2(x+random+self.length,y+random))
	return points

