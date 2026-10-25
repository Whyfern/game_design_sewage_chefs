extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.emit_signal("HUDloaded", self)
	pass # Replace with function body.
