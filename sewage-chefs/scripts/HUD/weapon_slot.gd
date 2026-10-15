extends TextureRect

@onready var weapon_icon: TextureRect = $WeaponIcon	

func update_weapon_display(weapon_texture: Texture) -> void:
	if weapon_texture:
		weapon_icon.texture = weapon_texture
		weapon_icon.visible = true
