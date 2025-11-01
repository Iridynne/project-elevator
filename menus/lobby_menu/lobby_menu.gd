class_name LobbyMenu extends Control

@onready var player_count: Label = %PlayerCount
@onready var player_list: VBoxContainer = %PlayerList
@onready var start_button: Button = %StartButton

@onready var entry_scene: PackedScene = preload("res://menus/lobby_menu/lobby_entry.tscn")

@export var entries: Dictionary[int, LobbyEntry] = {}


func _ready() -> void:
	# Reset LobbyMenu
	if not multiplayer.is_server(): start_button.hide()
	for child in player_list.get_children():
		child.queue_free()
	
	# Connect Signals
	NetworkHandler.peer_connected.connect(_on_peer_connected)
	NetworkHandler.peer_disconnected.connect(_on_peer_disconnected)
	NetworkHandler.server_stopped.connect(_on_server_stopped)
	
	# Add Server player entry
	if multiplayer.is_server():
		add_entry(multiplayer.get_unique_id())


func add_entry(id: int) -> void:
	if entries.has(id): return
	
	var entry: LobbyEntry = entry_scene.instantiate()
	entry.name = str(id)
	player_list.add_child(entry, true)
	entry.set_player_name.rpc_id(id, "Player %d" % id)
	
	# Save id - entry pair for easy removal later
	entries.set(id, entry)
	
	# Update count
	_update_count()


func remove_entry(id: int) -> void:
	if not entries.has(id): return
	
	# Delete entry and remove it from dictionary
	var entry: LobbyEntry = entries.get(id)
	entry.queue_free()
	entries.erase(id)
	
	# Update count
	_update_count()


func _update_count() -> void:
	var entry_count: int = len(entries.keys())
	player_count.text = "%d / %d" % [entry_count, NetworkHandler.MAX_CLIENTS + 1]


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server(): return
	add_entry(id)


func _on_peer_disconnected(id: int) -> void:
	remove_entry(id)


func _on_server_stopped() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(Global.MAIN_MENU)


func _on_start_button_pressed() -> void:
	_start_game.rpc()


@rpc("any_peer", "call_local")
func _start_game() -> void:
	get_tree().change_scene_to_file(Global.GAME_LEVEL)
