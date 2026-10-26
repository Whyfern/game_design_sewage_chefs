extends Resource
class_name WeaponData

# One weapon type, saved as a .tres file in res://resources/weapons/

@export var weaponName: String = "Weapon"
@export var icon: Texture2D

@export_category("Stats")
@export var damage: int = 60
@export var attackSpeed: float = 0.5
