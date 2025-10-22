extends Control

@export var address_entry: LineEdit


func _on_host_button_pressed() -> void:
	NetworkHandler.start_server()


func _on_join_button_pressed() -> void:
	if not address_entry.text: return
	
	NetworkHandler.join_server(address_entry.text)
