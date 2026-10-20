

extends Area2D

@export var ingredient_name: String = "Onion"

@onready var interactable = get_node_or_null("interactable_ingredient")
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	update_sprite()
	
	print("Ingredient ready!")
	print("Found child: ", interactable)

	if interactable == null:
		print("ERROR: Could not find interactable_ingredient!")
		return

	interactable.interactName = "Collect " + ingredient_name + " (press e)"
	interactable.interact = _on_interact
	

func _on_interact() -> void:
	#print("Collected: ", ingredient_name)
	#queue_free()
	var collected_ingredient = InventoryManager.add_ingredient(ingredient_name)
	if collected_ingredient:
		print("Collected: ", ingredient_name)
		queue_free()

func update_sprite() -> void:
	var sprite_paths = {
		"Apple": "res://sprites/ingredients_assets/apple.png",
		"Green Bell Pepper": "res://sprites/ingredients_assets/bell pepper green.png",
		"Onion": "res://sprites/ingredients_assets/onion.png",
		"Brisket": "res://sprites/ingredients_assets/brisket.png",
		"Cheese Brie": "res://sprites/ingredients_assets/cheese brie.png",
		"Tuna Steak": "res://sprites/ingredients_assets/tuna steak.png",
		"T Bone": "res://sprites/ingredients_assets/t bone.png",
		"Cherries": "res://sprites/ingredients_assets/cherry.png",
		"Red Bell Pepper": "res://sprites/ingredients_assets/bell pepper red.png",
		"Pumpkin": "res://sprites/ingredients_assets/pumpkin.png",
		"Cucumber": "res://sprites/ingredients_assets/cucumber.png",
		"Duck Breast": "res://sprites/ingredients_assets/duck breast.png",
		"Corn": "res://sprites/ingredients_assets/corn.png",
		"Dragonfruit": "res://sprites/ingredients_assets/dragonfruit.png",
		"Lettuce": "res://sprites/ingredients_assets/lettuce.png",
		"Mango": "res://sprites/ingredients_assets/mango.png",
		"Potato": "res://sprites/ingredients_assets/potato.png",
		"Cheese Mozzarella": "res://sprites/ingredients_assets/cheese mozzarella.png",
		"Tomato": "res://sprites/ingredients_assets/tomato.png",
		"Lobster": "res://sprites/ingredients_assets/lobster.png",
		"Short Ribs": "res://sprites/ingredients_assets/short ribs.png",
		"Carrot": "res://sprites/ingredients_assets/carrot.png",
		"Asparagus": "res://sprites/ingredients_assets/asparagus.png",
		"Parsnip": "res://sprites/ingredients_assets/parsnip.png",
		"Radish": "res://sprites/ingredients_assets/radish.png",
		"Garlic": "res://sprites/ingredients_assets/garlic.png",
		"New York Strip": "res://sprites/ingredients_assets/new york strip.png"
	}

	if sprite_paths.has(ingredient_name):
		var texture_path: String = sprite_paths[ingredient_name]
		var texture = load(texture_path) as Texture2D

		if texture != null:
			sprite.texture = texture
		else:
			print("Could not load sprite: ", texture_path)
	else:
		print("No sprite found for: ", ingredient_name)
