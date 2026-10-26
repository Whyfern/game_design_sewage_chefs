extends Node

# Autoload "WeaponInventory": the weapons the player carries (3 slots)

signal weapons_changed
signal equipped_changed(slotIndex: int)

const SLOT_COUNT: int = 3
const STARTING_WEAPON_ID: String = "spatula"

var slots: Array[WeaponData] = []
var equippedSlot: int = 0


func _ready() -> void:
	slots.resize(SLOT_COUNT)
	slots.fill(null)
	slots[0] = GameManager.get_weapon(STARTING_WEAPON_ID)


# returns the weapon in the currently selected slot (can be null if that slot is empty)
func get_equipped_weapon() -> WeaponData:
	return slots[equippedSlot]


func get_weapon_in_slot(slotIndex: int) -> WeaponData:
	if slotIndex < 0 or slotIndex >= SLOT_COUNT:
		return null
	return slots[slotIndex]


func has_free_slot() -> bool:
	return slots.has(null)


# puts a weapon in a free slot, or swaps it with the equipped one and returns that
func add_weapon(weapon: WeaponData) -> WeaponData:
	if weapon == null:
		return null

	var freeSlot: int = slots.find(null)
	if freeSlot != -1:
		slots[freeSlot] = weapon
		weapons_changed.emit()
		if slots[equippedSlot] == null:
			equip_slot(freeSlot)
		return null

	var swappedWeapon: WeaponData = slots[equippedSlot]
	slots[equippedSlot] = weapon
	weapons_changed.emit()
	equipped_changed.emit(equippedSlot)
	return swappedWeapon


func equip_slot(slotIndex: int) -> void:
	if slotIndex < 0 or slotIndex >= SLOT_COUNT or slotIndex == equippedSlot:
		return
	equippedSlot = slotIndex
	equipped_changed.emit(equippedSlot)


# direction: +1 = next slot, -1 = previous slot (wraps around)
func cycle_slot(direction: int) -> void:
	equip_slot(posmod(equippedSlot + direction, SLOT_COUNT))


# switch slots with 1-3 and the mouse wheel
func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventKey and event.pressed and not event.echo:
		var keyIndex: int = event.physical_keycode - KEY_1
		if keyIndex >= 0 and keyIndex < SLOT_COUNT:
			equip_slot(keyIndex)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cycle_slot(-1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cycle_slot(1)
			get_viewport().set_input_as_handled()


# back to only the starting weapon in slot 1 (used when a new game starts)
func reset() -> void:
	slots.fill(null)
	slots[0] = GameManager.get_weapon(STARTING_WEAPON_ID)
	equippedSlot = 0
	weapons_changed.emit()
	equipped_changed.emit(equippedSlot)
