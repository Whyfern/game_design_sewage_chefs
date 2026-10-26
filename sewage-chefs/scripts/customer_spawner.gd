extends Node

@export var customer_scene: PackedScene
var entrance_paths: Array[Path2D] = []

var min_spawn_time: float = 5
var max_spawn_time: float = 15

@export var order_icons: Array[Texture2D] = []

@onready var spawn_timer: Timer = $SpawnTimer
@export var max_customers: int = 8

var spawned_customers: int = 0
var occupied_paths: Array[Path2D] = []


#func _ready() -> void:
	#spawn_timer.one_shot = true
	#spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	#schedule_next_customer()



func _ready() -> void:

	
	print("Min spawn time: ", min_spawn_time)
	print("Max spawn time: ", max_spawn_time)
	
	for child in get_children():
		if child is Path2D:
			entrance_paths.append(child)
	
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	schedule_next_customer()
	

func get_available_paths() -> Array[Path2D]:
	var available_paths: Array[Path2D] = []

	for path in entrance_paths:
		if path != null and not occupied_paths.has(path):
			available_paths.append(path)

	return available_paths
	
	
func schedule_next_customer() -> void:
	spawn_timer.start(randf_range(min_spawn_time, max_spawn_time))


func _on_spawn_timer_timeout() -> void:
	if spawned_customers >= max_customers:
		return

	if spawn_customer():
		spawned_customers += 1

	if spawned_customers < max_customers and not get_available_paths().is_empty():
		schedule_next_customer()


func spawn_customer() -> bool:
	var available_paths = get_available_paths()

	if available_paths.is_empty():
		return false

	var selected_path: Path2D = available_paths.pick_random()

	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false
	path_follow.y_sort_enabled = true

	selected_path.add_child(path_follow)

	var customer: Customer = customer_scene.instantiate()

	
	path_follow.add_child(customer)
	occupied_paths.append(selected_path)

	customer.departed.connect(_on_customer_departed)

	customer.start_walking()
	return true
	
	
	
func _on_customer_departed(path: Path2D) -> void:
	occupied_paths.erase(path)
	spawned_customers = maxi(0, spawned_customers - 1)

	if spawn_timer.is_stopped() and spawned_customers < max_customers and not get_available_paths().is_empty():
		schedule_next_customer()
