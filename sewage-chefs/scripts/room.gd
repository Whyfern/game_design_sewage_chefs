extends Node2D
class_name room

@onready var levelMan = get_node("../../..")
@onready var sewerRoom01 = load("res://scenes/sewer rooms/sewer_room_01.tscn")
var sewerRoomInstance
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
	if type == 1:
		setStartRoomPos()

func setStartRoomPos():
	sewerRoomInstance = sewerRoom01.instantiate()
	self.add_child.call_deferred(sewerRoomInstance)
	print("this is start pos", grid_pos)
	levelMan.startPos = grid_pos
	EventBus.emit_signal("startRoomPos")
	pass
