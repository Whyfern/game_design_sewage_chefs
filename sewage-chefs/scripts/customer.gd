
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
		
		complete_order()
		start_leaving()
	else:
		print("You don't have: ", requested_dish)



func start_leaving() -> void:
	is_leaving = true
	is_walking = true
	interactable.set_deferred("monitorable", false)
