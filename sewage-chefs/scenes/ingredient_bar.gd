
extends HBoxContainer

const SLOT_COUNT: int = 5

@export var slotTexture: Texture2D = preload("res://sprites/Rats/inventory slot.png")
@export var slotSize: Vector2 = Vector2(80, 80)

var slotNodes: Array[TextureRect] = []
var iconNodes: Array[TextureRect] = []

var ingredient_sprites = {
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


func _ready() -> void:
	build_slots()
	InventoryManager.inventory_changed.connect(refresh_icons)
	refresh_icons()


func build_slots() -> void:
	for i in range(SLOT_COUNT):
		var slot := TextureRect.new()
		slot.texture = slotTexture
		slot.custom_minimum_size = slotSize
		slot.size = slotSize
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slotNodes.append(slot)
		add_child(slot)

		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.position = Vector2(0, 0)
		icon.size = slotSize
		slot.add_child(icon)
		iconNodes.append(icon)

		# Number each ingredient slot from 1 to 9.
		var keyLabel := Label.new()
		keyLabel.text = str(i + 1)
		keyLabel.position = Vector2(5, 2)
		keyLabel.add_theme_font_size_override("font_size", 14)
		keyLabel.add_theme_color_override("font_color", Color.WHITE)
		keyLabel.add_theme_color_override("font_outline_color", Color.BLACK)
		keyLabel.add_theme_constant_override("outline_size", 4)
		slot.add_child(keyLabel)


func refresh_icons() -> void:
	for i in range(SLOT_COUNT):
		if i < InventoryManager.ingredients.size():
			var ingredient_name = InventoryManager.ingredients[i]
			var path: String = ingredient_sprites.get(ingredient_name, "")
			if path != "":
				iconNodes[i].texture = load(path)
			else:
				iconNodes[i].texture = null
		else:
			iconNodes[i].texture = null
