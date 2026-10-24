extends Node

signal stats_changed

var current_day: int = 1
var money: int = 50
var mafia_debt: int = 50
var debt_increase_daily: int = 25

func add_money(amount: int) -> void:
	money += amount
	stats_changed.emit()

func pay_mafia() -> bool:
	if money >= mafia_debt:
		money -= mafia_debt
		stats_changed.emit()
		return true
	return false

func next_day() -> void:
	current_day += 1
	mafia_debt += debt_increase_daily
	stats_changed.emit()


const WEAPONS: Dictionary = {
	"spatula": preload("res://resources/weapons/spatula.tres"),
	"kitchen_knife": preload("res://resources/weapons/kitchen_knife.tres"),
	"meat_tenderizer": preload("res://resources/weapons/meat_tenderizer.tres"),
}

# returns the weapon with this id, or null (with a warning) if it does not exist
func get_weapon(weapon_id: String) -> WeaponData:
	if not WEAPONS.has(weapon_id):
		push_warning("GameManager: no weapon with id '" + weapon_id + "'")
		return null
	return WEAPONS[weapon_id]

func has_weapon(weapon_id: String) -> bool:
	return WEAPONS.has(weapon_id)

func get_all_weapon_ids() -> Array:
	return WEAPONS.keys()

# useful later for enemy drops
func get_random_weapon() -> WeaponData:
	return WEAPONS.values().pick_random()


# ---------------------------------------------------------------------------
# INGREDIENT DICTIONARY (NOT IN USE YET - everything below is commented out)
#
# One central dictionary with all ingredient information. Right now the game
# still uses:
#   - sprite_paths in scripts/ingredient_collectible.gd  (name -> image)
#   - the common / uncommon / rare lists in scripts/room.gd (spawn rarity)
# Nothing reads this part, so it does not change how the game works.
#
# To start using it later:
#   1. ingredient_collectible.gd: replace the sprite_paths dictionary with
#      GameManager.get_ingredient_icon(ingredient_name)
#   2. room.gd: replace the three lists with
#      GameManager.get_ingredients_with_rarity("common") / "uncommon" / "rare"
# ---------------------------------------------------------------------------

## rarity: "common" = near the start, "uncommon" = middle, "rare" = deep in the sewer
const INGREDIENTS: Dictionary = {
	# --- common ---
	"Apple": {"icon": "res://sprites/ingredients_assets/apple.png", "rarity": "common"},
	"Onion": {"icon": "res://sprites/ingredients_assets/onion.png", "rarity": "common"},
	"Cucumber": {"icon": "res://sprites/ingredients_assets/cucumber.png", "rarity": "common"},
	"Mango": {"icon": "res://sprites/ingredients_assets/mango.png", "rarity": "common"},
	"Tomato": {"icon": "res://sprites/ingredients_assets/tomato.png", "rarity": "common"},
	"Dragonfruit": {"icon": "res://sprites/ingredients_assets/dragonfruit.png", "rarity": "common"},
	"Cherries": {"icon": "res://sprites/ingredients_assets/cherry.png", "rarity": "common"},

	# --- uncommon ---
	"Cheese Mozzarella": {"icon": "res://sprites/ingredients_assets/cheese mozzarella.png", "rarity": "uncommon"},
	"Cheese Brie": {"icon": "res://sprites/ingredients_assets/cheese brie.png", "rarity": "uncommon"},
	"Pumpkin": {"icon": "res://sprites/ingredients_assets/pumpkin.png", "rarity": "uncommon"},
	"Radish": {"icon": "res://sprites/ingredients_assets/radish.png", "rarity": "uncommon"},
	"Parsnip": {"icon": "res://sprites/ingredients_assets/parsnip.png", "rarity": "uncommon"},
	"Asparagus": {"icon": "res://sprites/ingredients_assets/asparagus.png", "rarity": "uncommon"},
	"Carrot": {"icon": "res://sprites/ingredients_assets/carrot.png", "rarity": "uncommon"},
	"Potato": {"icon": "res://sprites/ingredients_assets/potato.png", "rarity": "uncommon"},
	"Corn": {"icon": "res://sprites/ingredients_assets/corn.png", "rarity": "uncommon"},
	"Lettuce": {"icon": "res://sprites/ingredients_assets/lettuce.png", "rarity": "uncommon"},

	# --- rare ---
	"Brisket": {"icon": "res://sprites/ingredients_assets/brisket.png", "rarity": "rare"},
	"Tuna Steak": {"icon": "res://sprites/ingredients_assets/tuna steak.png", "rarity": "rare"},
	"T Bone": {"icon": "res://sprites/ingredients_assets/t bone.png", "rarity": "rare"},
	"Duck Breast": {"icon": "res://sprites/ingredients_assets/duck breast.png", "rarity": "rare"},
	"New York Strip": {"icon": "res://sprites/ingredients_assets/new york strip.png", "rarity": "rare"},
	"Short Ribs": {"icon": "res://sprites/ingredients_assets/short ribs.png", "rarity": "rare"},
	"Lobster": {"icon": "res://sprites/ingredients_assets/lobster.png", "rarity": "rare"},

	# --- have a sprite but do not spawn yet (not in the room.gd lists) ---
	"Green Bell Pepper": {"icon": "res://sprites/ingredients_assets/bell pepper green.png", "rarity": "unused"},
	"Red Bell Pepper": {"icon": "res://sprites/ingredients_assets/bell pepper red.png", "rarity": "unused"},
	"Garlic": {"icon": "res://sprites/ingredients_assets/garlic.png", "rarity": "unused"},
}

func has_ingredient(ingredient_name: String) -> bool:
	return INGREDIENTS.has(ingredient_name)
#
## loads the sprite of an ingredient, or returns null if it is unknown
func get_ingredient_icon(ingredient_name: String) -> Texture2D:
	if not INGREDIENTS.has(ingredient_name):
		push_warning("GameManager: unknown ingredient '" + ingredient_name + "'")
		return null
	return load(INGREDIENTS[ingredient_name]["icon"])

func get_ingredient_rarity(ingredient_name: String) -> String:
	if not INGREDIENTS.has(ingredient_name):
		return ""
	return INGREDIENTS[ingredient_name]["rarity"]
#
## all ingredient names of one rarity, e.g. get_ingredients_with_rarity("rare")
func get_ingredients_with_rarity(rarity: String) -> Array[String]:
	var names: Array[String] = []
	for ingredient_name in INGREDIENTS:
		if INGREDIENTS[ingredient_name]["rarity"] == rarity:
			names.append(ingredient_name)
	return names


func get_ingredient_price(ingredient_name: String) -> int:
	if not INGREDIENTS.has(ingredient_name):
		push_warning("Unknown ingredient: " + ingredient_name)
		return 0

	var rarity: String = INGREDIENTS[ingredient_name]["rarity"]

	match rarity:
		"common":
			return 10
		"uncommon":
			return 20
		"rare":
			return 35
		_:
			return 0
