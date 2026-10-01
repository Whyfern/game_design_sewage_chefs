extends Node

@onready var restaurant = load('res://scenes/restaurant.tscn')
@onready var sewer = load('res://scenes/sewer.tscn')
@onready var sewerGeneration = load("res://scenes/room_generator.tscn")

@onready var main = get_node("..")

var restaurantInstance : Node = null
var sewerInstance : Node = null
var restaurantState = false

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
		if sewerInstance:
			sewerInstance.queue_free()
		restaurantState = true
	

func instantiate_level():
	if restaurantState:
		print("toilet flushed");
		sewerInstance = sewer.instantiate()
		sewerInstance.z_index = 0
		main.add_child.call_deferred(sewerInstance)
		if restaurantInstance:
			restaurantInstance.queue_free()
		restaurantState = false
		pass

	#var restraunt = 1
	#
	#if instance and is_instance_valid(instance):
		#instance.queue_free()
		#instance = null
	#+
	#instance_count += 1
	#instance = creation_panel.instantiate()
	#instance.name = "creationpanel%d" % instance_count
	#UI.add_child.call_deferred(instance)
