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
			
			#important part. calls the method interact inside of the object which your are 
			#interacting with. and waits until it is done before it continues.
			await currentInteractions[0].interact.call()
			
			canInteract = true

#the process that shows and hides the interaction label as well as initiates the sorting
func _process(delta: float) -> void:
	if currentInteractions and canInteract:
		currentInteractions.sort_custom(_sort_by_nearest)
		if currentInteractions[0].isInteractable:
			interactLabel.text = currentInteractions[0].interactName
			
			interactLabel.show()
	else:
		interactLabel.hide()
		pass

#used for sorting by distance
func _sort_by_nearest(area1, area2):
	var areaDist1 = global_position.distance_to(area1)
	var areaDist2 = global_position.distance_to(area2)
	return areaDist1 < areaDist2

#for adding interactables into the array of currentInteractions
func _on_interact_range_area_entered(area: Area2D) -> void:
	currentInteractions.push_back(area)
	print("has entered");
	print(currentInteractions);
	print(currentInteractions[0].interactName);
	print(interactLabel.text);

#for removing interactables from the array of currentInteractions
func _on_interact_range_area_exited(area: Area2D) -> void:
	currentInteractions.erase(area)
	print("has exited");
	print(currentInteractions);
