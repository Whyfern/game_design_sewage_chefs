extends Area2D
class_name WeaponPickup

# A weapon lying on the floor that the player can pick up with E.

const PICKUP_SCENE_PATH: String = "res://scenes/weapon_pickup.tscn"

@export var weapon: WeaponData
@export var weaponId: String = ""
@export var iconSize: float = 32.0

@onready var interactableWeapon: interactable = $interactable_weapon
@onready var sprite: Sprite2D = $Sprite2D


static func spawn(weaponToDrop: WeaponData, dropPosition: Vector2, parentNode: Node) -> WeaponPickup:
	var pickup: WeaponPickup = load(PICKUP_SCENE_PATH).instantiate()
	pickup.weapon = weaponToDrop
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
		queue_free()
	else:
		weapon = swappedWeapon
		update_display()
