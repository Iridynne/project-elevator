class_name GameLevel extends Node3D

var player_scene: PackedScene = preload("res://player/player.tscn")

var players: Dictionary[int, Player] = {}


func _ready() -> void:
	NetworkHandler.peer_connected.connect(_on_peer_connected)
	NetworkHandler.peer_disconnected.connect(_on_peer_disconnected)
	NetworkHandler.server_stopped.connect(_on_server_stopped)
	
	if multiplayer.is_server():
		add_player(multiplayer.get_unique_id())
		for peer_id in multiplayer.get_peers():
			add_player(peer_id)


func add_player(id: int) -> void:
	if players.has(id): return
	
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	add_child(player, true)
	
	players.set(id, player)


func remove_player(id: int) -> void:
	if not players.has(id): return
	
	var player: Player = players.get(id)
	player.queue_free()
	players.erase(id)


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server(): return
	add_player(id)


func _on_peer_disconnected(id: int) -> void:
	remove_player(id)


func _on_server_stopped() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(Global.MAIN_MENU)
