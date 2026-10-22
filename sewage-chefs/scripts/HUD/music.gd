extends AudioStreamPlayer

var is_tense_mode: bool = false

func _ready() -> void:
	if not playing:
		play()
	# a new day starts when the mafia debt is paid
	EventBus.debt_paid.connect(restart_music)

# Call this function when your clock hits the final 60 seconds
func trigger_tense_music() -> void:
	if is_tense_mode: 
		return
	is_tense_mode = true
	
	# Smoothly pitch up the music to make it sound tense and fast-paced
	var tween = create_tween()
	tween.tween_property(self, "pitch_scale", 1.25, 1.0) # Speeds up pitch to 1.25x over 1 second

# Call this if the player pays off debt or time resets
func reset_music_pitch() -> void:
	is_tense_mode = false
	var tween = create_tween()
	tween.tween_property(self, "pitch_scale", 1.0, 1.0)

# starts the song from the beginning at normal speed (new day)
func restart_music() -> void:
	is_tense_mode = false
	pitch_scale = 1.0
	play(0.0)
