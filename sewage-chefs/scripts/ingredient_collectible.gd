extends StaticBody2D

@onready var interactable : Area2D = $Interactable
@export var ingredient_name: String = "Onion"
@onready var pickup_sound: AudioStreamPlayer = $AudioStreamPlayer
#@onready var drop_sound: AudioStreamPlayer = $AudioStreamPlayer2
#pickup_sound.volume_db = 6.0

#@onready var interactable = get_node_or_null("interactable_ingredient")
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
	
	pickup_sound.volume_db = 0.0
	

func _on_interact() -> void:
	#print("Collected: ", ingredient_name)
	#queue_free()
	var collected_ingredient = InventoryManager.add_ingredient(ingredient_name)
	if collected_ingredient:
		print("Collected: ", ingredient_name)
		print("Playing pickup sound!")
		pickup_sound.play()
		print("Sound playing: ", pickup_sound.playing)
		await pickup_sound.finished
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
		"New York Strip": "res://sprites/ingredients_assets/new york strip.png",
		
		"Garlic Bread": "res://sprites/ingredients_assets/49_garlicbread_dish.png",
		"Hotdog": "res://sprites/ingredients_assets/56_hotdog_dish.png",
		"Bagel": "res://sprites/ingredients_assets/21_bagel_dish.png",
		"Fried egg": "res://sprites/ingredients_assets/39_friedegg_dish.png",
		"French fries": "res://sprites/ingredients_assets/45_frenchfries_dish.png",
		"Taco": "res://sprites/ingredients_assets/100_taco_dish.png",
		"Pizza": "res://sprites/ingredients_assets/82_pizza_dish.png",
		"Apple pie": "res://sprites/ingredients_assets/06_apple_pie_dish.png",
		"Burger": "res://sprites/ingredients_assets/16_burger_dish.png",
		"Burrito": "res://sprites/ingredients_assets/19_burrito_dish.png",
		"Cheesecake": "res://sprites/ingredients_assets/23_cheesecake_dish.png",
		"Chocolate cake": "res://sprites/ingredients_assets/31_chocolatecake_dish.png",
		"Roasted chicken": "res://sprites/ingredients_assets/86_roastedchicken_dish.png",
		"Salmon": "res://sprites/ingredients_assets/89_salmon_dish.png",
		"Spaghetti Bolognese": "res://sprites/ingredients_assets/94_spaghetti.png",
		"Steak": "res://sprites/ingredients_assets/96_steak_dish.png",
		"Sushi": "res://sprites/ingredients_assets/98_sushi_dish.png"
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
