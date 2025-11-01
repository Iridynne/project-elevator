class_name LobbyEntry extends PanelContainer

@export var player_name: String = "Player 1":
	set=set_player_name

@onready var name_label: Label = %Name


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


@rpc("any_peer", "call_local")
func set_player_name(value: String) -> void:
	player_name = value
	%Name.text = player_name
