extends Node2D
class_name room

var grid_pos: Vector2
var type: int

var door_top: bool
var door_bot: bool
var door_left: bool
var door_right: bool

var sprite : Sprite2D

func _init(pos: Vector2 = Vector2.ZERO, room_type: int = 0) -> void:
	grid_pos = pos
	type = room_type

func _ready() -> void:
	print("room" , grid_pos)
