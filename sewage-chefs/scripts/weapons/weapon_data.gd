extends Resource
class_name WeaponData

# Describes one weapon type. Each weapon is saved as a .tres file in
# res://resources/weapons/ so its stats can be tweaked in the Inspector
# without touching any code.

@export var weaponName: String = "Weapon"
@export var icon: Texture2D

@export_category("Stats")
# damage dealt per hit (the player currently uses attackDamage = 60)
@export var damage: int = 60
# seconds one attack takes (the player currently uses attackSpeed = 0.5)
@export var attackSpeed: float = 0.5
