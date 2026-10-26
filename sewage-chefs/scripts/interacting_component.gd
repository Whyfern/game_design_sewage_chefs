extends Node2D
class_name interactingComponent

@onready var interactLabel: Label = $interactLabel
var currentInteractions := []
var canInteract := true



#this is used to process the input for interaction.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and canInteract:
		if currentInteractions:
			canInteract = false
			interactLabel.hide()
			get_viewport().set_input_as_handled()
			#important part. calls the method interact inside of the object which your are 
			#interacting with. and waits until it is done before it continues.
			await currentInteractions[0].interact.call()
			
			canInteract = true

#the process that shows and hides the interaction label as well as initiates the sorting
func _process(delta: float) -> void:
	if currentInteractions and canInteract:
		currentInteractions.sort_custom(_sort_by_nearest)
		if currentInteractions[0].isInteractable:
			#only ingredients care about a full inventory
			var isIngredient: bool = currentInteractions[0].get_parent().get("ingredient_name") != null
			if isIngredient and InventoryManager.ingredients.size() >= InventoryManager.max_ingredients:
				interactLabel.text = "Inventory full! Press Q to drop items"
			else:
				interactLabel.text = currentInteractions[0].interactName
			
			interactLabel.show()
	else:
		interactLabel.hide()
		pass

#used for sorting by distance
func _sort_by_nearest(area1, area2):
	var areaDist1 = global_position.distance_to(area1.global_position)
	var areaDist2 = global_position.distance_to(area2.global_position)
	return areaDist1 < areaDist2

#for adding interactables into the array of currentInteractions
func _on_interact_range_area_entered(area: Area2D) -> void:
	if GameManager.interactPrint:
		print("AREA DETECTED: ", area.name)

	if not "interactName" in area:
		return

	currentInteractions.push_back(area)
	if GameManager.interactPrint:
		print("has entered")
		print(currentInteractions)
		print(area.interactName)
		print(interactLabel.text)
	pass


#for removing interactables from the array of currentInteractions
func _on_interact_range_area_exited(area: Area2D) -> void:
	currentInteractions.erase(area)
	if GameManager.interactPrint:
		print("has exited");
		print(currentInteractions);
