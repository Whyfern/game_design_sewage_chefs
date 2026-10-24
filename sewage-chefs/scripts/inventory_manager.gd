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


func has_ingredient(ingredient_name: String) -> bool:
	return ingredients.has(ingredient_name)


func remove_ingredient(ingredient_name: String) -> bool:
	if not has_ingredient(ingredient_name):
		return false

	ingredients.erase(ingredient_name)
	inventory_changed.emit()

	return true
