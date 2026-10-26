extends Node2D

func _ready() -> void:
	scale = Vector2.ONE
	$AnimationPlayer.play("enemy_death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "enemy_death":
		queue_free()
