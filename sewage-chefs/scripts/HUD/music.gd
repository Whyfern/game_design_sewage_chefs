extends AudioStreamPlayer

const RESTAURANT_MUSIC: AudioStream = preload(
	"res://Music/GameMusic.ogg"
)
const SEWER_MUSIC: AudioStream = preload(
	"res://Music/sewage_ambience_ost.wav"
)
var is_tense_mode: bool = false

# A separate player lets kitchen ambience overlap the restaurant music.
@onready var kitchenAmbience: AudioStreamPlayer = $"../KitchenAmbience"


func _ready() -> void:
	EventBus.locationChanged.connect(_on_location_changed)
	EventBus.deadlineApproaching.connect(trigger_tense_music)
	# Main starts in the restaurant.
	_on_location_changed("restaurant")


func _on_location_changed(location: String) -> void:
	var nextTrack: AudioStream
	match location:
		"restaurant":
			nextTrack = RESTAURANT_MUSIC
		"sewer":
			nextTrack = SEWER_MUSIC
		_:
			return
	# Avoid restarting the music if the same location is announced again.
	if stream != nextTrack or not playing:
		stream = nextTrack
		play()

	# Start the kitchen layer alongside restaurant music, and silence it in sewers.
	# It has its own volume and pitch, independent of the deadline music effect.
	if location == "restaurant":
		if not kitchenAmbience.playing:
			kitchenAmbience.play()
	else:
		kitchenAmbience.stop()
	
	
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
