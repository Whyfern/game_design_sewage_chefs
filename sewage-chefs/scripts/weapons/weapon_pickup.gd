extends Area2D
class_name WeaponPickup

# A weapon lying on the floor that the player can pick up with E.
# Works like ingredient_collectible: it uses an interactable child node.
#
# Later, enemies can drop one with:
#   WeaponPickup.spawn(weaponData, global_position, get_parent())

const PICKUP_SCENE_PATH: String = "res://scenes/weapon_pickup.tscn"

@export var weapon: WeaponData
# Optional: type a weapon id from GameManager.WEAPONS here (e.g. "meat_tenderizer") instead of
# dragging a .tres file into "weapon". If filled in, it overrides "weapon".
@export var weaponId: String = ""
# how big the icon is drawn in the world, in pixels (icons have different sizes)
@export var iconSize: float = 32.0

@onready var interactableWeapon: interactable = $interactable_weapon
@onready var sprite: Sprite2D = $Sprite2D


static func spawn(weaponToDrop: WeaponData, dropPosition: Vector2, parentNode: Node) -> WeaponPickup:
	var pickup: WeaponPickup = load(PICKUP_SCENE_PATH).instantiate()
	pickup.weapon = weaponToDrop
	# convert to the parent's local space, because the pickup is not in the tree yet
	if parentNode is Node2D:
		pickup.position = parentNode.to_local(dropPosition)
	else:
		pickup.position = dropPosition
	parentNode.add_child.call_deferred(pickup)
	return pickup


func _ready() -> void:
	interactableWeapon.interact = _on_interact
	if weaponId != "" and GameManager.has_weapon(weaponId):
		weapon = GameManager.get_weapon(weaponId)
	elif weaponId != "":
		push_warning("WeaponPickup: unknown weaponId '" + weaponId + "'")
	update_display()


# refreshes the sprite and the "Pick up ..." text for the current weapon
func update_display() -> void:
	if weapon == null:
		push_warning("WeaponPickup has no weapon assigned: " + str(get_path()))
		interactableWeapon.isInteractable = false
		return

	sprite.texture = weapon.icon
	if weapon.icon != null:
		var textureSize: Vector2 = weapon.icon.get_size()
		var largestSide: float = max(textureSize.x, textureSize.y)
		sprite.scale = Vector2.ONE * (iconSize / largestSide)

	interactableWeapon.interactName = "Pick up " + weapon.weaponName + " (press e)"
	interactableWeapon.isInteractable = true


func _on_interact() -> void:
	var swappedWeapon: WeaponData = WeaponInventory.add_weapon(weapon)

	if swappedWeapon == null:
		# there was a free slot, the pickup is gone
		queue_free()
	else:
		# inventory was full: the old equipped weapon is left on the floor here
		weapon = swappedWeapon
		update_display()
