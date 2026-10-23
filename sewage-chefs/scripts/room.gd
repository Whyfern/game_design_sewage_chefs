extends Node2D
class_name room

@onready var levelMan = get_node("../../..")
@onready var ingredient_scene = preload("res://scenes/ingredient_collectible.tscn")
@onready var toilet = load("res://scenes/toilet.tscn")

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
var depth: int = 0

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
		assemble_room(false)
	elif type == 1:
		assemble_room(true)
		set_Start_Room_Pos()
	#$Label.text = str(door_top, ":top,  ", door_left, ":left,  ", door_bot, ":bot,  ", door_right, ":right")

func set_Start_Room_Pos():
	levelMan.startPos = grid_pos
	EventBus.emit_signal("startRoomPos")
	pass

func assemble_room(start : bool):
	if start:
		choose_floor(true)
		place_toilet()
	else:
		choose_floor(false)
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
	boundaryInstance = boundary.instantiate()
	self.add_child.call_deferred(boundaryInstance)

func place_toilet():
	var toiletInstance = toilet.instantiate()
	toiletInstance.position = Vector2(1280/2, 704/2)
	self.add_child.call_deferred(toiletInstance)

func test_boundary():
	print(door_top, ":top,  ", door_left, ":left,  ", door_bot, ":bot,  ", door_right, ":right")
	print(boundary)
	
	
	
func spawn_ingredients():
	var common_ingredients = [
		"Apple",
		"Onion",
		"Cucumber",
		"Mango",
		"Tomato",
		"Dragonfruit",
		"Cherries",
		#"Green Bell Pepper",
		#"Red Bell Pepper"
	]

	var uncommon_ingredients = [
		"Cheese Mozarella",
		"Cheese Brie",
		"Pumpkin",
		"Radish",
		"Parsnip",
		"Asparagus",
		"Carrot",
		"Potato",
		"Corn",
		"Lettuce"
	]

	var rare_ingredients = [
		"Brisket",
		"Tuna Steak",
		"T Bone",
		"Duck Breast",
		"New York Strip",
		"Short Ribs",
		"Lobster"
	]

	var spawn_markers = floorInstance.find_children(
		"FoodSpawn*",
		"Marker2D",
		true,
		false
	)

	for marker in spawn_markers:
		# Keep the existing 40% spawn chance.
		if randf() > 0.4:
			continue

		var ingredient_options = common_ingredients

		# Deeper rooms have better odds of uncommon and rare food.
		var rarity_roll = randf()

		if depth >= 3 and rarity_roll < 0.90:
			ingredient_options = rare_ingredients
		elif depth >= 2 and rarity_roll < 0.70:
			ingredient_options = uncommon_ingredients
		elif depth >= 2 and rarity_roll < 0.40:
			ingredient_options = rare_ingredients
		elif depth >= 1 and rarity_roll < 0.20:
			ingredient_options = uncommon_ingredients

		var ingredient = ingredient_scene.instantiate()
		ingredient.ingredient_name = ingredient_options.pick_random()

		floorInstance.add_child(ingredient)
		ingredient.global_position = marker.global_position

func choose_floor(start : bool):
	floorsKeys = floorsDict.keys()
	randomKey = floorsKeys.pick_random()
	if start:
		floor = load("res://scenes/sewer rooms/sewer_room_floors/sewer_room_00.tscn")
	else :
		floor = floorsDict[randomKey]
	#print("Is start room: ", start)
	floorInstance = floor.instantiate()
	#print("Loaded floor scene: ", floor.resource_path)
	add_child(floorInstance)
	#self.add_child.call_deferred(floorInstance)
	
	spawn_ingredients()
