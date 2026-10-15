

extends Area2D

@export var ingredient_name: String = "Onion"

@onready var interactable = get_node_or_null("interactable_ingredient")

func _ready() -> void:
	print("Ingredient ready!")
	print("Found child: ", interactable)

	if interactable == null:
		print("ERROR: Could not find interactable_ingredient!")
		return

	interactable.interactName = "Collect " + ingredient_name + " (press e)"
	interactable.interact = _on_interact

func _on_interact() -> void:
	print("Collected: ", ingredient_name)
	queue_free()
