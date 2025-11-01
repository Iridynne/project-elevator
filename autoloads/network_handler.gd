extends Node
## An autoload that manages all networking setup and events
##
## This class handles creating and connecting to multiplayer servers using the [ENetMultiplayerPeer].
## It provides convenient signals for connection lifecycle events and automatically sets up
## UPNP port forwarding when hosting a server.

## Emitted when server is created
signal server_started
## Emitted when server is closed
signal server_stopped
## Emitted when peer connects
signal peer_connected(id: int)
## Emitted when peer disconnects
signal peer_disconnected(id: int)
## Emitted when successfully connected to server
signal connected_to_server
## Emitted when connection to server failed
signal connection_failed

## Default port of the created server
const DEFAULT_PORT: int = 27017
## Maximum amount of clients allowed to connect to the server
const MAX_CLIENTS: int = 3

## Default IP of the created client
const DEFAULT_IP: String = "127.0.0.1"


func _ready() -> void:
	# Hook up multiplayer events
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

## Create a server with a given [param port]
func create_server(port: int = DEFAULT_PORT) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port, MAX_CLIENTS)
	if error != Error.OK:
		push_error("Failed to create server on port %d" % port)
		return
	
	multiplayer.multiplayer_peer = peer
	server_started.emit()
	print("Server started on port %d" % port)
	
	# Setup UPNP port forwarding if supported
	_upnp_setup(port)

## Create a client with a given [param ip] and [param port]
func create_client(ip: String = DEFAULT_IP, port: int = DEFAULT_PORT) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, port)
	if error != Error.OK:
		push_error("Failed to create client on %s:%d" % [ip, port])
		return
	
	multiplayer.multiplayer_peer = peer
	print("Connecting to %s:%d..." % [ip, port])


func _on_peer_connected(id: int) -> void:
	print("Peer connected: %d" % id)
	peer_connected.emit(id)


func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: %d" % id)
	peer_disconnected.emit(id)


func _on_connected_to_server() -> void:
	print("Connected to server")
	connected_to_server.emit()


func _on_connection_failed() -> void:
	print("Connection failed")
	connection_failed.emit()


func _on_server_disconnected() -> void:
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	server_stopped.emit()


func _upnp_setup(port: int) -> void:
	var upnp: UPNP = UPNP.new()
	var discover_result: int = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		push_error("UPNP Discover Failed! Error: %s" % discover_result)
		return
	
	if not upnp.get_gateway() or not upnp.get_gateway().is_valid_gateway():
		push_error("UPNP Invalid Gateway!")
		return
	
	var map_result: int = upnp.add_port_mapping(port)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		push_error("UPNP Port Mapping Failed! Error: %s" % map_result)
		return
	
	var external_ip: String = upnp.query_external_address()
	print("Join Address: %s" % external_ip)
