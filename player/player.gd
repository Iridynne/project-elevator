class_name Player extends CharacterBody3D

@export_category("Character")
## The speed of the Player when moving normally
@export var base_speed: float = 3
## The speed of the Player while sprinting
@export var sprint_speed: float = 6
## The speed of the Player while crouching
@export var crouch_speed: float = 1

## How fast the Player speeds up and slows down
@export var acceleration: float = 10
## How high the Player jumps
@export var jump_velocity: float = 5
## How fast the Player turns when mouse is moved
@export var mouse_sensitivity: float = 0.1

@export_group("References")
## Reference to Camera pivot node
@export var camera_pivot: Node3D
## Reference to Camera3D node
@export var camera: Camera3D

@export_group("Controls")
@export var input_forward: String = "ui_up"
@export var input_backward: String = "ui_down"
@export var input_left: String = "ui_left"
@export var input_right: String = "ui_right"
@export var input_jump: String = "ui_accept"
@export var input_sprint: String = "sprint"
@export var input_crouch: String = "crouch"

@export_group("Controller Specific")
@export var input_look_up: String = "look_up"
@export var input_look_down: String = "look_down"
@export var input_look_left: String = "look_left"
@export var input_look_right: String = "look_right"
@export_range(0.001, 1, 0.001) var look_sensitivity: float = 0.035

@export_group("Feature Settings")
## Can the Player move?
@export var can_move: bool = true
## Can the PLayer jump?
@export var can_jump: bool = true
## Can the Player sprint?
@export var can_sprint: bool = true
## Can the Player crouch?
@export var can_crouch: bool = true

var move_speed: float = base_speed

# Get gravity from Project Settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	_check_controls()


func _physics_process(_delta: float) -> void:
	# Handle movement
	if can_move:
		var input_dir: Vector2 = Input.get_vector(input_left, input_right, input_forward, input_backward)
		var forward: Vector3 = camera.global_transform.basis.z
		var right: Vector3 = camera.global_transform.basis.x
		
		var move_dir: Vector3 = forward * input_dir.y + right * input_dir.x
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.y * move_speed
		else:
			velocity.x = 0
			velocity.z = 0
	
	move_and_slide()


## Check and disable the unmapped actions
func _check_controls() -> void:
	if !InputMap.has_action(input_forward):
		push_error("No mapping for move forward. Disabling movement.")
		can_move = false
	
	if !InputMap.has_action(input_backward):
		push_error("No mapping for move backward. Disabling movement.")
		can_move = false
	
	if !InputMap.has_action(input_left):
		push_error("No mapping for move left. Disabling movement.")
		can_move = false
	
	if !InputMap.has_action(input_right):
		push_error("No mapping for move right. Disabling movement.")
		can_move = false
	
	if !InputMap.has_action(input_jump):
		push_error("No mapping for jumping. Disabling jumping.")
		can_jump = false
	
	if !InputMap.has_action(input_sprint):
		push_error("No mapping for sprinting. Disabling sprinting.")
		can_sprint = false
	
	if !InputMap.has_action(input_crouch):
		push_error("No mapping for crouching. Disabling crouching.")
		can_crouch = false
