extends Node

@onready var main = get_node("..")
@onready var charMan = get_node("../character_manager")
@onready var playChar = get_node("../character_manager/Player_Character")
@onready var restaurant = load('res://scenes/restaurant.tscn')
@onready var roomGeneration = load("res://scenes/room_generator.tscn")

var restaurantInstance : Node = null

var sewerInstance : Node = null
var sewerGenerationInstance : Node = null
var roomGenerationInstance : Node = null

var restaurantState = false

var startPos : Vector2

#starting variables for the grid can be set here
@export var roomValue = 10
@export var gridSize : Vector2 = Vector2(5, 5)
@export var roomSize : Vector2 = Vector2(1280, 704)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("toiletFlushed", switch_level)
	instatiate_restaurant()
	pass

func switch_level():
	if restaurantState:
		instantiate_level()
	elif !restaurantState:
		instatiate_restaurant()

func instatiate_restaurant():
	if !restaurantState:
		
		restaurantInstance = restaurant.instantiate()
		restaurantInstance.z_index = 0
		main.add_child.call_deferred(restaurantInstance)
		
		if sewerGenerationInstance:
			sewerGenerationInstance.queue_free()
		restaurantState = true
	pass

func instantiate_level():
	if restaurantState:
		roomGenerationInstance = roomGeneration.instantiate()
		roomGenerationInstance.roomValue = roomValue
		roomGenerationInstance.roomSize = roomSize
		roomGenerationInstance.gridSize = gridSize
		self.add_child.call_deferred(roomGenerationInstance)
		
		await EventBus.startRoomPos
		startPos = startPos * roomSize
		startPos = startPos + 0.5 * roomSize
		playChar.position = startPos
		if restaurantInstance:
			restaurantInstance.queue_free()
		restaurantState = false
	pass
