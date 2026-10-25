extends Node

@onready var main = get_node("..")
@onready var charMan = get_node("../character_manager")
@onready var playChar = get_node("../character_manager/Player_Character")
@onready var sewageBar = get_node("../CanvasLayer/TextureProgressBar")
@onready var restaurant = load('res://scenes/restaurant.tscn')
@onready var roomGeneration = load("res://scenes/room_generator.tscn")
@onready var sewageMan = load("res://scenes/sewage_manager.tscn")

var sewageManInstance : Node = null

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

#place where the player starts in the restaurant
@export var charStartRest : Vector2 = Vector2(400, 430)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("toiletFlushed", switch_level)
	#EventBus.connect("gridGeneratorInstantiated")
	instatiate_restaurant()
	pass

#checks if the sewer or the restaurant should be switched to 
func switch_level():
	if restaurantState:
		instantiate_sewer()
	elif !restaurantState:
		instatiate_restaurant()

#used to spawn the restaurant also dewpawn the sewer
func instatiate_restaurant():
	if !restaurantState:
		
		
		if not is_instance_valid(restaurantInstance):
			restaurantInstance = restaurant.instantiate()
			restaurantInstance.z_index = 0

		if restaurantInstance.get_parent() == null:
			main.add_child.call_deferred(restaurantInstance)

		
		startPos = charStartRest
		playChar.position = startPos
		sewageBar.isFlooding = false
		
		EventBus.emit_signal("switchCameraState", "restaurant")
		
		if roomGenerationInstance:
			roomGenerationInstance.queue_free()
			sewageManInstance.queue_free()
			sewageBar.visible = false
		restaurantState = true
	pass

#used to spawn the sewer while also despawning the restaurant. It works by instantiating room generatioin and sewage manager
func instantiate_sewer():
	if restaurantState:
		roomGenerationInstance = roomGeneration.instantiate()
		roomGenerationInstance.roomValue = roomValue
		roomGenerationInstance.roomSize = roomSize
		roomGenerationInstance.gridSize = gridSize
		self.add_child.call_deferred(roomGenerationInstance)
		
		await EventBus.gridGeneratorInstantiated
		sewageManInstance = sewageMan.instantiate()
		sewageManInstance.roomValue = roomValue
		sewageManInstance.roomSize = roomSize
		print(roomGenerationInstance.get_currently())
		sewageManInstance.possibilities = roomGenerationInstance.get_currently()
		self.add_child.call_deferred(sewageManInstance)
		
		sewageBar.sewageMan = sewageManInstance
		sewageBar.set_parameters()
		sewageBar.visible = true
		
		EventBus.emit_signal("switchCameraState", "sewer")
		
		await EventBus.startRoomPos
		startPos = startPos * roomSize
		startPos = startPos + 0.5 * roomSize
		playChar.position = startPos
		
		if is_instance_valid(restaurantInstance) and restaurantInstance.get_parent() == main:
			main.remove_child.call_deferred(restaurantInstance)

		restaurantState = false

	pass
