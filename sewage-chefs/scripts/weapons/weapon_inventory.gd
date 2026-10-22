extends Node

# Autoload "WeaponInventory": keeps track of the weapons the player carries.
# This is separate from InventoryManager, which stores collected ingredients.
#
# Other scripts can use:
#   WeaponInventory.get_equipped_weapon() -> WeaponData (or null)
#   WeaponInventory.add_weapon(weapon)    -> WeaponData that had to be swapped out (or null)
#   WeaponInventory.equip_slot(index)
#   signals weapons_changed / equipped_changed(slotIndex)

signal weapons_changed
signal equipped_changed(slotIndex: int)

const SLOT_COUNT: int = 3
# id (from the weapon dictionary in GameManager) of the weapon the player starts with in slot 1
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


# Puts a weapon in the first empty slot.
# If every slot is full, the weapon in the equipped slot is replaced and returned,
# so the caller (for example a pickup on the floor) can leave it behind.
func add_weapon(weapon: WeaponData) -> WeaponData:
	if weapon == null:
		return null

	var freeSlot: int = slots.find(null)
	if freeSlot != -1:
		slots[freeSlot] = weapon
		weapons_changed.emit()
		# auto-equip the new weapon if the player was holding nothing
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


# Slot switching: number keys 1-3 and the mouse wheel.
# Handled here so the player script does not need to change for now.
func _unhandled_input(event: InputEvent) -> void:
	if Dialogue.is_active:
		return

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
