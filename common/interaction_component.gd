class_name InteractionComponent extends Node3D

@onready var interact_canvas: CanvasLayer = $CanvasLayer
@onready var interact_label: Label = %InteractLabel

var current_interactions: Array[InteractionArea] = []
var can_interact: bool = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_canvas.hide()
			
			await current_interactions[0].interact.call()
			
			can_interact = true


func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable:
			interact_label.text = current_interactions[0].interact_name
			interact_canvas.show()
	else:
		interact_canvas.hide()


func _sort_by_nearest(area1: InteractionArea, area2: InteractionArea) -> bool:
	var area1_dist: float = global_position.distance_to(area1.global_position)
	var area2_dist: float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist


func _on_interact_range_area_entered(area: Area3D) -> void:
	if area is InteractionArea:
		current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area3D) -> void:
	if area is InteractionArea:
		current_interactions.erase(area)
