extends Node

@onready var main = get_node("..")
@onready var restaurant = load('res://scenes/restaurant.tscn')
@onready var roomGeneration = load("res://scenes/room_generator.tscn")

var restaurantInstance : Node = null

var sewerInstance : Node = null
var sewerGenerationInstance : Node = null
var roomGenerationInstance : Node = null

var restaurantState = false

var grid : Array 

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
		#await get_tree().create_timer(2.0).timeout
		self.add_child.call_deferred(roomGenerationInstance)
		
		if restaurantInstance:
			restaurantInstance.queue_free()
		restaurantState = false
	pass
