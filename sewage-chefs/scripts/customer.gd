
extends CharacterBody2D
class_name Customer

@export var speed: float = 300.0
@export var requested_item_icon: Texture2D
@export var requested_dish: String = "Asparagus"

@onready var path_follow: PathFollow2D = get_parent() as PathFollow2D
@onready var order_bubble: PanelContainer = $OrderBubble
@onready var order_icon: TextureRect = $OrderBubble/MarginContainer/OrderIcon
@onready var interactable: Area2D = $Interactable
@onready var serve_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var rarity_label: Label = $RarityLabel

signal departed(path: Path2D)

var is_leaving: bool = false
var is_walking: bool = false

# patience timer: the customer leaves without paying when it runs out
@export var patience_time: float = 45.0
@export var patience_only_in_restaurant: bool = true
@export var patience_bar_rect: Rect2 = Rect2(-32, -52, 64, 7)
var patience_left: float = 0.0
var is_waiting: bool = false
var player_in_restaurant: bool = true
var patience_bar: ProgressBar
var patience_fill: StyleBoxFlat


func _ready() -> void:
	order_bubble.hide()
	rarity_label.hide()
	interactable.set_deferred("monitorable", false)

	var possible_orders: Array[String] = []

	var roll := randf()

	if roll < 0.45:
		possible_orders.append_array(GameManager.get_ingredients_with_rarity("common"))
	elif roll < 0.80:
		possible_orders.append_array(GameManager.get_ingredients_with_rarity("uncommon"))
	else:
		possible_orders.append_array(GameManager.get_ingredients_with_rarity("rare"))

	if not possible_orders.is_empty():
		requested_dish = possible_orders.pick_random()

	var rarity := GameManager.get_ingredient_rarity(requested_dish)
	var price := GameManager.get_ingredient_price(requested_dish)

	rarity_label.text = "$" + str(price)
	rarity_label.add_theme_font_size_override("font_size", 16)
	rarity_label.add_theme_font_size_override("font_size", 16)
	rarity_label.add_theme_color_override("font_outline_color", Color.BLACK)
	rarity_label.add_theme_constant_override("outline_size", 3)

	match rarity:
		"common":
			rarity_label.add_theme_color_override("font_color", Color.GREEN)
		"uncommon":
			rarity_label.add_theme_color_override("font_color", Color.DODGER_BLUE)
		"rare":
			rarity_label.add_theme_color_override("font_color", Color.MEDIUM_PURPLE)

	interactable.interactName = "Serve " + requested_dish
	interactable.interact = serve_customer

	make_patience_bar()
	var spawner: Node = get_parent().get_parent().get_parent() if get_parent() else null
	if spawner != null and spawner.get("current_location") != null:
		player_in_restaurant = spawner.current_location == "restaurant"
	EventBus.locationChanged.connect(_on_location_changed)

func start_walking() -> void:
	path_follow.progress = 0.0
	is_walking = true


func _physics_process(delta: float) -> void:
	if not is_walking:
		return

	if is_leaving:
		path_follow.progress = maxf(0.0, path_follow.progress - speed * delta)

		if path_follow.progress <= 0.0:
			is_walking = false
			departed.emit(path_follow.get_parent() as Path2D)
			path_follow.queue_free()

		return

	path_follow.progress += speed * delta

	if path_follow.progress_ratio >= 1.0:
		is_walking = false
		show_order()


func show_order() -> void:
	var icon: Texture2D = GameManager.get_ingredient_icon(requested_dish)

	if icon == null:
		return

	order_icon.texture = icon
	#order_icon.scale = Vector2(0.7, 0.7)
	rarity_label.show()
	order_bubble.show()
	interactable.set_deferred("monitorable", true)
	start_patience()

func complete_order() -> void:
	order_bubble.hide()
	rarity_label.hide()
	
	

func serve_customer() -> void:
	if is_walking or not order_bubble.visible or GameManager.time_is_up:
		return

	if InventoryManager.remove_ingredient(requested_dish):
		serve_sound.play(8.0)
		#await get_tree().create_timer(2.0).timeout
		#serve_sound.stop()
		print("Order completed: ", requested_dish)

		var payment: int = GameManager.get_ingredient_price(requested_dish)
		GameManager.add_money(payment)
		
		stop_patience()
		complete_order()
		start_leaving()
	else:
		print("You don't have: ", requested_dish)



func start_leaving() -> void:
	is_leaving = true
	is_walking = true
	interactable.set_deferred("monitorable", false)


func make_patience_bar() -> void:
	patience_bar = ProgressBar.new()
	patience_bar.show_percentage = false
	patience_bar.position = patience_bar_rect.position
	patience_bar.size = patience_bar_rect.size
	patience_bar.custom_minimum_size = patience_bar_rect.size
	patience_bar.max_value = 1.0
	patience_bar.step = 0.0
	patience_bar.value = 1.0

	var background := StyleBoxFlat.new()
	background.bg_color = Color(0, 0, 0, 0.6)
	background.set_corner_radius_all(3)
	patience_fill = StyleBoxFlat.new()
	patience_fill.bg_color = Color(0.3, 0.85, 0.3)
	patience_fill.set_corner_radius_all(3)
	patience_bar.add_theme_stylebox_override("background", background)
	patience_bar.add_theme_stylebox_override("fill", patience_fill)

	patience_bar.hide()
	add_child(patience_bar)


func start_patience() -> void:
	patience_left = patience_time
	is_waiting = true
	update_patience_bar()
	patience_bar.show()


func stop_patience() -> void:
	is_waiting = false
	patience_bar.hide()


func _process(delta: float) -> void:
	if not is_waiting:
		return
	if patience_only_in_restaurant and not player_in_restaurant:
		return

	patience_left -= delta
	update_patience_bar()
	if patience_left <= 0.0:
		run_out_of_patience()


func update_patience_bar() -> void:
	var ratio: float = clampf(patience_left / patience_time, 0.0, 1.0)
	patience_bar.value = ratio
	if ratio > 0.5:
		patience_fill.bg_color = Color(0.95, 0.85, 0.2).lerp(Color(0.3, 0.85, 0.3), (ratio - 0.5) * 2.0)
	else:
		patience_fill.bg_color = Color(0.9, 0.2, 0.15).lerp(Color(0.95, 0.85, 0.2), ratio * 2.0)


func run_out_of_patience() -> void:
	stop_patience()
	complete_order()
	rarity_label.text = "Too slow!"
	rarity_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.15))
	rarity_label.show()
	print("Customer left without ordering: ", requested_dish)
	start_leaving()


func _on_location_changed(location: String) -> void:
	player_in_restaurant = location == "restaurant"
