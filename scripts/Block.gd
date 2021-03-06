class_name Block
extends Node2D

var DEBUGGING: bool

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
var square_shakes: bool = false
var wobble_period: float = 0.01 # bigger number = slower
var shake_period: float = 0.02

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
# TODO: increase wobble for smaller grid sizes (at 10 pixel grid,
# standing wobble is too small)

var max_wobble_deviation: float
var max_shake_deviation: float
# Grow/Shrink by a random amount
var rng = RandomNumberGenerator.new()

onready var grid: Grid = Grid.new()

var parent_node: Node

func _ready():
	# Inherit parent.DEBUGGING if this scene is not the entry point.
	parent_node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING
	else:
		DEBUGGING = true

	# Player starts as a normal square shape.
	# Player size matches grid tile size.
	length = grid.SIZE
	# Center player artwork about player's position.
	top_left -= Vector2(length/2.0, length/2.0)
	self.square_points = normal_square()
	WOBBLE_AMOUNT = 0.024
	WOBBLE_AMOUNT_WHILE_MOVING = WOBBLE_AMOUNT * 3.0
	# WOBBLE_AMOUNT = 4.0 / grid.SIZE
	SHAKE_AMOUNT = 1.0 / grid.SIZE
	# Player's shape deviates with a wobbly effecet.
	max_wobble_deviation = grid.SIZE * WOBBLE_AMOUNT
	# Player's shape deviates with a shaky effecet.
	max_shake_deviation = grid.SIZE * SHAKE_AMOUNT

	if DEBUGGING:
		print("Running Block.gd: {n}._ready()... ".format({
			"n": name,
			}))
		print("Wobble: (standing:{w}, moving:{wm})".format({
			"w": WOBBLE_AMOUNT,
			"wm": WOBBLE_AMOUNT_WHILE_MOVING,
			}))
		print("Shake: {s}".format({
			"s": SHAKE_AMOUNT,
			}))

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
# TODO: how do I "turn off" _process() when parent node is
# disconnected (controller is removed)?
func _process(delta):
	if square_wobbles:
		delta_sum += delta
		if delta_sum >= self.wobble_period:
			# self.square_points = random_shaky_square()
			self.square_points = random_wobbly_square()
			# Reset the wobble period timer
			delta_sum = 0
	elif square_shakes:
		delta_sum += delta
		if delta_sum >= self.shake_period:
			self.square_points = random_shaky_square()
			# self.square_points = random_wobbly_square()
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
	# `length` is `grid.SIZE` all game long.
	# But I'm leaving this here for future effects.
	# 1) Use with `self.top_left` for shrinking/growing.
	length = d
	update()


func set_color(c: Color) -> void:
	color = c
	update()


# Larger deviation communicates block is in motion.
func express_motion():
	square_shakes = false
	square_wobbles = true
	self.max_wobble_deviation = grid.SIZE * WOBBLE_AMOUNT_WHILE_MOVING


func express_pooping():
	square_wobbles = false
	square_shakes = true
	# print("I'm pooping here")
	self.square_points = random_shaky_square()


# Restore deviation to original amount when standing still.
func express_standing_still():
	square_wobbles = true
	self.max_wobble_deviation = grid.SIZE * WOBBLE_AMOUNT


func express_connected():
	express_standing_still()
	self.color.a = 1.0 # max alpha

func express_disconnected():
	# TODO: remembering to put all possible "animations" here is
	# stupid, find a better design for "freezing" the sprite's
	# appearance when joystick disconnects.
	square_shakes = false
	square_wobbles = false
	self.color.a = 0.3 # low-alpha gives sprite faded-out look

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

