extends Node

signal stats_changed

var current_day: int = 1
var money: int = 50
var mafia_debt: int = 50
var debt_increase_daily: int = 25
var time_is_up: bool = false

#list of print messages that can be turned on by switching these variables
var interactPrint : bool = false
var sewageAreaOverlap : bool = true


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
	#"Apple": {"icon": "res://sprites/ingredients_assets/apple.png", "rarity": "common"},
	#"Onion": {"icon": "res://sprites/ingredients_assets/onion.png", "rarity": "common"},
	#"Cucumber": {"icon": "res://sprites/ingredients_assets/cucumber.png", "rarity": "common"},
	#"Mango": {"icon": "res://sprites/ingredients_assets/mango.png", "rarity": "common"},
	#"Tomato": {"icon": "res://sprites/ingredients_assets/tomato.png", "rarity": "common"},
	#"Dragonfruit": {"icon": "res://sprites/ingredients_assets/dragonfruit.png", "rarity": "common"},
	#"Cherries": {"icon": "res://sprites/ingredients_assets/cherry.png", "rarity": "common"},
	
	"Garlic Bread": {"icon": "res://sprites/ingredients_assets/49_garlicbread_dish.png", "rarity": "common"},
	"Hotdog": {"icon": "res://sprites/ingredients_assets/56_hotdog_dish.png", "rarity": "common"},
	"Bagel": {"icon": "res://sprites/ingredients_assets/21_bagel_dish.png", "rarity": "common"},
	"Fried egg": {"icon": "res://sprites/ingredients_assets/39_friedegg_dish.png", "rarity": "common"},
	"French fries": {"icon": "res://sprites/ingredients_assets/45_frenchfries_dish.png", "rarity": "common"},

	# --- uncommon ---
	#"Cheese Mozzarella": {"icon": "res://sprites/ingredients_assets/cheese mozzarella.png", "rarity": "uncommon"},
	#"Cheese Brie": {"icon": "res://sprites/ingredients_assets/cheese brie.png", "rarity": "uncommon"},
	#"Pumpkin": {"icon": "res://sprites/ingredients_assets/pumpkin.png", "rarity": "uncommon"},
	#"Radish": {"icon": "res://sprites/ingredients_assets/radish.png", "rarity": "uncommon"},
	#"Parsnip": {"icon": "res://sprites/ingredients_assets/parsnip.png", "rarity": "uncommon"},
	#"Asparagus": {"icon": "res://sprites/ingredients_assets/asparagus.png", "rarity": "uncommon"},
	#"Carrot": {"icon": "res://sprites/ingredients_assets/carrot.png", "rarity": "uncommon"},
	#"Potato": {"icon": "res://sprites/ingredients_assets/potato.png", "rarity": "uncommon"},
	#"Corn": {"icon": "res://sprites/ingredients_assets/corn.png", "rarity": "uncommon"},
	#"Lettuce": {"icon": "res://sprites/ingredients_assets/lettuce.png", "rarity": "uncommon"},
	
	"Taco": {"icon": "res://sprites/ingredients_assets/100_taco_dish.png", "rarity": "uncommon"},
	"Pizza": {"icon": "res://sprites/ingredients_assets/82_pizza_dish.png", "rarity": "uncommon"},
	"Apple pie": {"icon": "res://sprites/ingredients_assets/06_apple_pie_dish.png", "rarity": "uncommon"},
	"Burger": {"icon": "res://sprites/ingredients_assets/16_burger_dish.png", "rarity": "uncommon"},
	"Burrito": {"icon": "res://sprites/ingredients_assets/19_burrito_dish.png", "rarity": "uncommon"},
	"Cheesecake": {"icon": "res://sprites/ingredients_assets/23_cheesecake_dish.png", "rarity": "uncommon"},
	"Chocolate cake": {"icon": "res://sprites/ingredients_assets/31_chocolatecake_dish.png", "rarity": "uncommon"},

	# --- rare ---
	#"Brisket": {"icon": "res://sprites/ingredients_assets/brisket.png", "rarity": "rare"},
	#"Tuna Steak": {"icon": "res://sprites/ingredients_assets/tuna steak.png", "rarity": "rare"},
	#"T Bone": {"icon": "res://sprites/ingredients_assets/t bone.png", "rarity": "rare"},
	#"Duck Breast": {"icon": "res://sprites/ingredients_assets/duck breast.png", "rarity": "rare"},
	#"New York Strip": {"icon": "res://sprites/ingredients_assets/new york strip.png", "rarity": "rare"},
	#"Short Ribs": {"icon": "res://sprites/ingredients_assets/short ribs.png", "rarity": "rare"},
	#"Lobster": {"icon": "res://sprites/ingredients_assets/lobster.png", "rarity": "rare"},
	"Roasted chicken": {"icon": "res://sprites/ingredients_assets/86_roastedchicken_dish.png", "rarity": "rare"},
	"Salmon": {"icon": "res://sprites/ingredients_assets/89_salmon_dish.png", "rarity": "rare"},
	"Spaghetti Bolognese": {"icon": "res://sprites/ingredients_assets/94_spaghetti.png", "rarity": "rare"},
	"Steak": {"icon": "res://sprites/ingredients_assets/96_steak_dish.png", "rarity": "rare"},
	"Sushi": {"icon": "res://sprites/ingredients_assets/98_sushi_dish.png", "rarity": "rare"},

	# --- have a sprite but do not spawn yet (not in the room.gd lists) ---
	#"Green Bell Pepper": {"icon": "res://sprites/ingredients_assets/bell pepper green.png", "rarity": "unused"},
	#"Red Bell Pepper": {"icon": "res://sprites/ingredients_assets/bell pepper red.png", "rarity": "unused"},
	#"Garlic": {"icon": "res://sprites/ingredients_assets/garlic.png", "rarity": "unused"},
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


# ---------------------------------------------------------------------------
# GAME OVER / NEW GAME
# GameManager.trigger_game_over("reason") opens the game over screen.
# reset_game() puts everything back to the start (used by Try Again / Main Menu).
# ---------------------------------------------------------------------------

const GAME_OVER_SCENE: String = "res://scenes/menus/game_over.tscn"

# text shown on the game over screen
var game_over_reason: String = ""
# starting values of the variables at the top, saved so reset_game() can restore them
var start_values: Dictionary = {}

func _ready() -> void:
	start_values = {
		"current_day": current_day,
		"money": money,
		"mafia_debt": mafia_debt,
		"tributes_paid": tributes_paid,
	}

# ends the game and opens the game over screen, for example:
#   GameManager.trigger_game_over("Ricardo was defeated in the sewer")
func trigger_game_over(reason: String = "Ricardo's cooking days are over.") -> void:
	game_over_reason = reason
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(GAME_OVER_SCENE)

# resets money, debt, day, ingredients, weapons and the clock for a new game
func reset_game() -> void:
	for key in start_values:
		set(key, start_values[key])
	game_over_reason = ""
	victory_reason = ""
	InventoryManager.reset()
	WeaponInventory.reset()
	TimerContainer.reset_day()
	LevelTransition.cancel()
	get_tree().paused = false
	stats_changed.emit()


# ---------------------------------------------------------------------------
# FINAL FIGHT / VICTORY
# Every day the player can refuse to pay Don Parmesan and fight his gang.
# Day FINAL_DAY is the last day: pay everything (victory) or fight.
# Every tribute paid makes one thug leave the Don's gang.
# ---------------------------------------------------------------------------

const FINAL_DAY: int = 5
const MAX_THUGS: int = 5
const BRIBE_PRICE: int = 20
const VICTORY_SCENE: String = "res://scenes/menus/victory.tscn"

# how many times the player has paid the Don (used for the size of his gang)
var tributes_paid: int = 0
# text shown on the victory screen
var victory_reason: String = ""

func is_final_day() -> bool:
	return current_day >= FINAL_DAY

# 5 thugs at the start, one less for every tribute paid, but always at least 1
func get_thug_count() -> int:
	return max(1, MAX_THUGS - tributes_paid)

# pays an amount if the player has enough money (used for bribes)
func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	stats_changed.emit()
	return true

# ends the game with a win and opens the victory screen, for example:
#   GameManager.trigger_victory("You paid off Don Parmesan. Free at last!")
func trigger_victory(reason: String = "The restaurant is yours!") -> void:
	victory_reason = reason
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(VICTORY_SCENE)
