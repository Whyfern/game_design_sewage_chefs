extends Node2D
class_name room

@onready var levelMan = get_node("../../..")
@onready var ingredient_scene = preload("res://scenes/ingredient_collectible.tscn")

var boundaryInstance

var boundariesDict : Dictionary
var boundary : Object

var floorsDict : Dictionary
var floorsKeys  : Array
var randomKey
var floor
var floorInstance

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

#the ready function checks if what the room type is and starting the room position and setting the starting pos
func _ready() -> void:
	if type == 2:
		assemble_room(false)
	elif type == 1:
		assemble_room(true)
		set_Start_Room_Pos()
	#$Label.text = str(door_top, ":top,  ", door_left, ":left,  ", door_bot, ":bot,  ", door_right, ":right")

#sets the point where the player starts in the sewer by sending a signal so the levelmanager
func set_Start_Room_Pos():
	levelMan.startPos = grid_pos
	EventBus.emit_signal("startRoomPos")
	pass

#this puts the boundary and the floor together, while also looking at if the room is the start
func assemble_room(start : bool):
	if start:
		choose_floor(true)
	else:
		choose_floor(false)
	choose_wall()

#by making a code from the doors that should open it makes the name of the boundary that should be used
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
	boundaryInstance = boundary.instantiate()
	self.add_child.call_deferred(boundaryInstance)

#test funtion
func test_boundary():
	print(door_top, ":top,  ", door_left, ":left,  ", door_bot, ":bot,  ", door_right, ":right")
	print(boundary)

func spawn_ingredients():
	print("Spawn function called!")
	print("Floor children: ", floorInstance.get_children())
	print("Has FoodSpawns child: ", floorInstance.has_node("FoodSpawns"))

	var spawn_markers = floorInstance.find_children(
		"FoodSpawn*",
		"Marker2D",
		true,
		false
	)

	print("Markers found: ", spawn_markers.size())

	for marker in spawn_markers:
		print("Marker position: ", marker.global_position)

		var ingredient = ingredient_scene.instantiate()
		floorInstance.add_child(ingredient)
		ingredient.global_position = marker.global_position

		print("Ingredient spawned at: ", ingredient.global_position)

func choose_floor(start : bool):
	floorsKeys = floorsDict.keys()
	randomKey = floorsKeys.pick_random()
	if start:
		floor = load("res://scenes/sewer rooms/sewer_room_floors/sewer_room_00.tscn")
	else :
		floor = floorsDict[randomKey]
	print("Is start room: ", start)
	floorInstance = floor.instantiate()
	print("Loaded floor scene: ", floor.resource_path)
	add_child(floorInstance)
	#self.add_child.call_deferred(floorInstance)
	
	spawn_ingredients()
