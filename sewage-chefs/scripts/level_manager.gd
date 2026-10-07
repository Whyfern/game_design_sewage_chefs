extends Node

@onready var restaurant = load('res://scenes/restaurant.tscn')
@onready var sewer = load('res://scenes/sewer.tscn')
@onready var sewerGeneration = load("res://scenes/grid_generator.tscn")

@onready var main = get_node("..")

var restaurantInstance : Node = null

var sewerInstance : Node = null
var sewerGenerationInstance : Node = null



var restaurantState = false

var grid : Array 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("toiletFlushed", switch_level)
	EventBus.connect("layoutGenerated", get_grid)
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
		sewerGenerationInstance = sewerGeneration.instantiate()
		self.add_child.call_deferred(sewerGenerationInstance)
		
		await EventBus.layoutGenerated 
		
		if restaurantInstance:
			restaurantInstance.queue_free()
		restaurantState = false
	pass

func get_grid():
	if sewerGenerationInstance:
		grid = sewerGenerationInstance.send_grid()
		test_print_Array()

func test_print_Array():
	for i in grid.size():
		print(grid[i])
