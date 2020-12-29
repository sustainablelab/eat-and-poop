extends Node


onready var block: ColorRect = $Block

func _ready() -> void:
	block.color = ColorN("lightsalmon", 1) # color, alpha
	# Set size with `set_size`
	# TODO: maybe custom drawing in 2D makes more sense?
	# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html#
