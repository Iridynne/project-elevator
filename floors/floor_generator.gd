class_name FloorGenerator extends Node3D

@export var room_templates: Array[PackedScene]
@export var grid_cell_size: float = 12
@export var floor_container: Node3D

var occupied_cells: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if floor_container == null:
		floor_container = self


func generate_floor() -> void:
	# Cleanup old floor
	for child in floor_container.get_children():
		child.queue_free()
