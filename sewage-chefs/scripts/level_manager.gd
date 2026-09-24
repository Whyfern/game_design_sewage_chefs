extends Node

@onready var restaurant = load('res://scenes/restaurant.tscn')
@onready var sewer = load('res://scenes/sewer.tscn')
@onready var main = get_node("..")

var restaurantInstance : Node = null
var sewerInstance : Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instatiate_restaurant()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func instatiate_restaurant():
	restaurantInstance = restaurant.instantiate()
	restaurantInstance.z_index = 0
	main.add_child.call_deferred(restaurantInstance)
	

func instantiate_level():
	sewerInstance = sewer.instantiate()
	sewerInstance.z_index = 0
	main.add_child.call_deferred(sewerInstance)
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
