extends Node3D

@export_category("References")
@export var address_entry: LineEdit


func _on_host_button_pressed() -> void:
	NetworkHandler.start_server()


func _on_join_button_pressed() -> void:
	var ip_address: String = address_entry.text
	if not ip_address: return
	
	NetworkHandler.join_server(ip_address)
