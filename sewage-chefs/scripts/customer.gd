
extends CharacterBody2D
class_name Customer

@export var speed: float = 150.0
@export var requested_item_icon: Texture2D

@onready var path_follow: PathFollow2D = get_parent() as PathFollow2D
@onready var order_bubble: PanelContainer = $OrderBubble
@onready var order_icon: TextureRect = $OrderBubble/MarginContainer/OrderIcon

var is_walking: bool = false


func _ready() -> void:
	order_bubble.hide()


func start_walking() -> void:
	path_follow.progress = 0.0
	is_walking = true


func _physics_process(delta: float) -> void:
	if not is_walking:
		return

	path_follow.progress += speed * delta

	if path_follow.progress_ratio >= 1.0:
		is_walking = false
		show_order()


func show_order() -> void:
	if requested_item_icon == null:
		return

	order_icon.texture = requested_item_icon
	order_bubble.show()


func complete_order() -> void:
	order_bubble.hide()
