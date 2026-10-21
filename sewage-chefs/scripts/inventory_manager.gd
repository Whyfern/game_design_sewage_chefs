extends Node

signal inventory_changed

var max_ingredients: int = 15
var ingredients: Array[String] = []

func add_ingredient(ingredient_name: String) -> bool:
	if ingredients.size() >= max_ingredients:
		print("Inventory full!")
		return false

	ingredients.append(ingredient_name)
	inventory_changed.emit()

	print("Inventory: ", ingredients)
	print("Ingredients: ", ingredients.size(), "/", max_ingredients)

	return true
