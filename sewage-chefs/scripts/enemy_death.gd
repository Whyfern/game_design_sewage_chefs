extends Node2D

@onready var deathSound: AudioStreamPlayer2D = $DeathSound


func _ready() -> void:
	scale = Vector2.ONE
	$AnimationPlayer.play("enemy_death")
	deathSound.play()


func _on_animation_player_animation_finished(
	anim_name: StringName
) -> void:
	if anim_name != "enemy_death":
		return

	# The visual effect is finished.
	$death_anim.hide()

	# Keep this scene alive if the sound still needs time.
	if deathSound.playing:
		await deathSound.finished

	queue_free()
