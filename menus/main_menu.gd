class_name MainMenu extends Control

@onready var address_entry: LineEdit = %AddressEntry


func _on_host_button_pressed() -> void:
	NetworkHandler.create_server()
	
	if not multiplayer.multiplayer_peer: return
	get_tree().change_scene_to_file(Global.LOBBY_MENU)


func _on_join_button_pressed() -> void:
	var stripped_entry: String = address_entry.text.strip_edges()
	var ip_address: String = "localhost" if not stripped_entry else stripped_entry
	NetworkHandler.create_client(ip_address)
	
	await NetworkHandler.connected_to_server
	get_tree().change_scene_to_file(Global.LOBBY_MENU)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
