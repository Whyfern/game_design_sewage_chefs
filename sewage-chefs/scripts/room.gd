extends Node2D
class_name room

@onready var levelMan = get_node("../../..")

var boundaryInstance

var boundariesDict : Dictionary
var boundary : Object
var floors : PackedStringArray

var sewerRoomInstance
var grid_pos: Vector2
var type: int

#True means open
var door_top: bool
var door_bot: bool
var door_left: bool
var door_right: bool

var sprite : Sprite2D

func _init(pos: Vector2 = Vector2.ZERO, room_type: int = 0) -> void:
	grid_pos = pos
	type = room_type

func _ready() -> void:
	if type == 2:
		assemble_room()
	elif type == 1:
		assemble_room()
		set_Start_Room_Pos()
	#$Label.text = str(door_top, ":top,  ", door_left, ":left,  ", door_bot, ":bot,  ", door_right, ":right")

func set_Start_Room_Pos():
	assemble_room()
	#sewerRoomInstance = sewerRoom01.instantiate()
	#self.add_child.call_deferred(sewerRoomInstance)
	#print("this is start pos", grid_pos)
	levelMan.startPos = grid_pos
	EventBus.emit_signal("startRoomPos")
	pass

func assemble_room():
	choose_wall()

func choose_wall():
	var code = ""
	if door_top:
		code += "T"
	if door_left:
		code += "L"
	if door_bot:
		code += "B"
	if door_right:
		code += "R"
	var file_name = "sewer_room_boundary_" + code + ".tscn"
	boundary = boundariesDict[file_name]
	$Label.text = code
	test_boundary()

func test_boundary():
	print(door_top, ":top,  ", door_left, ":left,  ", door_bot, ":bot,  ", door_right, ":right")
	print(boundary)
	boundaryInstance = boundary.instantiate()
	self.add_child.call_deferred(boundaryInstance)

func choose_floor():
	pass
