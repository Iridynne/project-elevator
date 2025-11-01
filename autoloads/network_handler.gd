extends Node
## Autoload that manages all networking setup and events
##
## Handles creating and connecting to multiplayer servers using the [ENetMultiplayerPeer].
## It provides convenient signals for connection lifecycle events and automatically sets up
## UPNP port forwarding when hosting a server (when possible).

## Emitted when server is created.
signal server_started
## Emitted when server is closed.
signal server_stopped
## Emitted when peer connects.
signal peer_connected(id: int)
## Emitted when peer disconnects.
signal peer_disconnected(id: int)
## Emitted when successfully connected to server.
signal connected_to_server
## Emitted when connection to server failed.
signal connection_failed
## Emitted when external IP address is discovered (UPNP only).
signal external_address_discovered(external_ip: String)

## Default port of the created server.
const DEFAULT_PORT: int = 27017
## Maximum amount of clients allowed to connect to the server.
const MAX_CLIENTS: int = 3

## Default IP of the created client.
const DEFAULT_IP: String = "127.0.0.1"


func _ready() -> void:
	# Hook up multiplayer events
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Create a server with a given [param port]. Also sets up [UPNP] if provided and supported
func create_server(port: int = DEFAULT_PORT, use_upnp: bool = false) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port, MAX_CLIENTS)
	if error != Error.OK:
		push_error("[NetworkHandler] Failed to create server on port %d" % port)
		return
	
	multiplayer.multiplayer_peer = peer
	server_started.emit()
	print("[NetworkHandler] Server started on port %d" % port)
	
	# Setup UPNP port forwarding if prompted and supported
	if use_upnp: _upnp_setup(port)


## Create a client with a given [param ip] and [param port].
func create_client(ip: String = DEFAULT_IP, port: int = DEFAULT_PORT) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, port)
	if error != Error.OK:
		push_error("[NetworkHandler] Failed to create client on %s:%d" % [ip, port])
		return
	
	multiplayer.multiplayer_peer = peer
	print("[NetworkHandler] Connecting to %s:%d..." % [ip, port])


## Closes any active server or client connection.
func close_connection() -> void:
	if not multiplayer.multiplayer_peer: return
	
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	server_stopped.emit()
	print("[NetworkHandler] Connection closed")


## Returns `true` if current peer is a server.
func is_server() -> bool:
	return multiplayer.is_server()


## Returns `true` if connected as a client.
func is_client() -> bool:
	return multiplayer.multiplayer_peer != null and not multiplayer.is_server()


## Returns `true` if any multiplayer session is active.
func is_network_connected() -> bool:
	return multiplayer.multiplayer_peer != null


func _on_peer_connected(id: int) -> void:
	print("[NetworkHandler] Peer connected: %d" % id)
	peer_connected.emit(id)


func _on_peer_disconnected(id: int) -> void:
	print("[NetworkHandler] Peer disconnected: %d" % id)
	peer_disconnected.emit(id)


func _on_connected_to_server() -> void:
	print("[NetworkHandler] Connected to server")
	connected_to_server.emit()


func _on_connection_failed() -> void:
	print("[NetworkHandler] Connection failed")
	connection_failed.emit()


func _on_server_disconnected() -> void:
	print("[NetworkHandler] Server disconnected")
	multiplayer.multiplayer_peer = null
	server_stopped.emit()


func _upnp_setup(port: int) -> void:
	var upnp: UPNP = UPNP.new()
	var discover_result: int = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		push_error("[NetworkHandler] UPNP Discover Failed! Error: %s" % discover_result)
		return
	
	if not upnp.get_gateway() or not upnp.get_gateway().is_valid_gateway():
		push_error("[NetworkHandler] UPNP Invalid Gateway!")
		return
	
	var map_result: int = upnp.add_port_mapping(port)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		push_error("[NetworkHandler] UPNP Port Mapping Failed! Error: %s" % map_result)
		return
	
	var external_ip: String = upnp.query_external_address()
	print("[NetworkHandler] Join Address: %s" % external_ip)
	external_address_discovered.emit(external_ip)
