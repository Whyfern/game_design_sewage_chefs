
extends Area2D

@export var ingredient_name: String = "Onion"

@onready var interactable: Area2D = $interactable_ingredient

func _ready() -> void:
	print("Ingredient ready!")

	interactable.interactName = "Collect " + ingredient_name
	interactable.interact = _on_interact

func _on_interact() -> void:
	print("Collected: ", ingredient_name)
	queue_free()
