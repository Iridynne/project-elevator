class_name PlayerSpawner extends Node

@export var player_scene: PackedScene


func _ready() -> void:
	NetworkHandler.peer_connected.connect(_on_peer_connected)
	NetworkHandler.peer_disconnected.connect(_on_peer_disconnected)
	NetworkHandler.connected_to_server.connect(_on_connected_to_server)
	
	if NetworkHandler.is_server:
		var id: int = multiplayer.get_unique_id()
		_spawn_player(id)


func _on_peer_connected(id: int) -> void:
	if NetworkHandler.is_server:
		_spawn_player(id)


func _on_peer_disconnected(id: int) -> void:
	var node_name = "Player_%d" % id
	var player: Player = get_node_or_null(node_name)
	if player:
		player.queue_free()


func _on_connected_to_server() -> void:
	var id: int = multiplayer.get_unique_id()
	rpc_id(1, "request_spawn", id)

@rpc("any_peer", "reliable")
func request_spawn(id: int) -> void:
	if not NetworkHandler.is_server:
		return
	_spawn_player(id)


func _spawn_player(id: int) -> void:
	var player: Player = player_scene.instantiate()
	player.name = "Player %d" % id
	player.set_multiplayer_authority(id)
	get_tree().current_scene.add_child(player)
