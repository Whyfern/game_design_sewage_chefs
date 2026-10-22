extends HBoxContainer

# Shows the 3 weapon slots at the bottom of the screen and highlights the
# equipped one. Listens to the WeaponInventory autoload, so nothing else
# has to update it.

@export var slotTexture: Texture2D = preload("res://sprites/Rats/inventory slot.png")
@export var slotSize: Vector2 = Vector2(80, 80)
# how much of the slot the weapon icon fills (0-1)
@export var iconFill: float = 0.6

@export var selectedColor: Color = Color(1, 1, 1, 1)
@export var unselectedColor: Color = Color(0.55, 0.55, 0.55, 0.85)
@export var selectedScale: float = 1.15

var slotNodes: Array[TextureRect] = []
var iconNodes: Array[TextureRect] = []


func _ready() -> void:
	build_slots()
	WeaponInventory.weapons_changed.connect(refresh_icons)
	WeaponInventory.equipped_changed.connect(_on_equipped_changed)
	refresh_icons()
	refresh_highlight()


func build_slots() -> void:
	for slotIndex in WeaponInventory.SLOT_COUNT:
		var slotBackground := TextureRect.new()
		slotBackground.texture = slotTexture
		slotBackground.custom_minimum_size = slotSize
		slotBackground.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slotBackground.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slotBackground.pivot_offset = slotSize / 2.0
		add_child(slotBackground)

		var weaponIcon := TextureRect.new()
		weaponIcon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		weaponIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		weaponIcon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var margin: Vector2 = slotSize * (1.0 - iconFill) / 2.0
		weaponIcon.position = margin
		weaponIcon.size = slotSize - margin * 2.0
		slotBackground.add_child(weaponIcon)

		# small key hint in the corner: 1, 2, 3
		var keyLabel := Label.new()
		keyLabel.text = str(slotIndex + 1)
		keyLabel.position = Vector2(6, 2)
		keyLabel.add_theme_font_size_override("font_size", 14)
		keyLabel.add_theme_color_override("font_color", Color.WHITE)
		keyLabel.add_theme_color_override("font_outline_color", Color.BLACK)
		keyLabel.add_theme_constant_override("outline_size", 4)
		slotBackground.add_child(keyLabel)

		slotNodes.append(slotBackground)
		iconNodes.append(weaponIcon)


func refresh_icons() -> void:
	for slotIndex in iconNodes.size():
		var weapon: WeaponData = WeaponInventory.get_weapon_in_slot(slotIndex)
		iconNodes[slotIndex].texture = weapon.icon if weapon else null


func refresh_highlight() -> void:
	for slotIndex in slotNodes.size():
		var isSelected: bool = slotIndex == WeaponInventory.equippedSlot
		var slotNode: TextureRect = slotNodes[slotIndex]
		slotNode.modulate = selectedColor if isSelected else unselectedColor
		var targetScale: Vector2 = Vector2.ONE * (selectedScale if isSelected else 1.0)
		create_tween().tween_property(slotNode, "scale", targetScale, 0.1)


func _on_equipped_changed(_slotIndex: int) -> void:
	refresh_icons()
	refresh_highlight()
