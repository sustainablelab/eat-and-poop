extends Node2D

func _ready() -> void:

	# Load the World scene
	var world_scene = preload("res://scenes/World.tscn")

	# Instantiate the World
	var world = world_scene.instance()

	# Make the world a child node of the Main scene
	add_child(world)
