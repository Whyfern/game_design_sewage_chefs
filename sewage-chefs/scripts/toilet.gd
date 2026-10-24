extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var flush_sound: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	flush_sound.play()
	EventBus.emit_signal("toiletFlushed")
