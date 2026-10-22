extends Camera2D

@onready var player: Node2D = get_node("..")
@onready var charMan : Node = get_node("../..")

@export var room_size: Vector2 = Vector2(1280, 704) 
@export var transition_speed: float = 5.0 

@onready var cameraState : String 

var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	EventBus.connect("switchCameraState", switch_mode)
	if player:
		target_position = _calculate_room_position(player.global_position)
		global_position = target_position

func _process(delta: float) -> void:
	if not player:
		return
		
	if cameraState == "sewer":
		top_level = true
		target_position = _calculate_room_position(player.global_position)
		global_position = global_position.lerp(target_position, transition_speed * delta)
	elif cameraState == "restaurant":
		top_level = false
		global_position = player.position

func _calculate_room_position(player_pos: Vector2) -> Vector2:
	var room_x : float = floor(player_pos.x / room_size.x)
	var room_y : float = floor(player_pos.y / room_size.y)
	
	var center_offset: Vector2 = room_size / 2.0
	return Vector2(room_x * room_size.x, room_y * room_size.y) + center_offset

func switch_mode(state : String):
	cameraState = state
