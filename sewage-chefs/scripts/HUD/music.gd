extends AudioStreamPlayer

const RESTAURANT_MUSIC: AudioStream = preload(
	"res://Music/GameMusic.ogg"
)
const SEWER_MUSIC: AudioStream = preload(
	"res://Music/sewage_ambience_ost.wav"
)
const SEWER_DRUMS: AudioStream = preload(
	"res://sfx/ambient/sewage_drums.wav"
)

@export_category("Combat music")
@export_range(-40.0, 0.0, 0.5) var combatLayerVolumeDb: float = -9.0
@export_range(0.1, 5.0, 0.1) var combatFadeInSeconds: float = 0.5
@export_range(0.1, 5.0, 0.1) var combatFadeOutSeconds: float = 1.5
@export_range(0.1, 10.0, 0.1) var combatReleaseSeconds: float = 2.0

const SILENT_LAYER_DB: float = -80.0
var sewerSoundtrack: AudioStreamSynchronized = AudioStreamSynchronized.new()
var currentLocation: String = "restaurant"
var combatActive: bool = false
var combatTween: Tween
var is_tense_mode: bool = false
var pitchTween: Tween

# A separate player lets kitchen ambience overlap the restaurant music.
@onready var kitchenAmbience: AudioStreamPlayer = $"../KitchenAmbience"
@onready var combatReleaseTimer: Timer = $"../CombatReleaseTimer"


func _ready() -> void:
	# Both stems start together. Only their relative volume changes during combat.
	sewerSoundtrack.stream_count = 2
	sewerSoundtrack.set_sync_stream(0, SEWER_MUSIC)
	sewerSoundtrack.set_sync_stream(1, SEWER_DRUMS)
	sewerSoundtrack.set_sync_stream_volume(0, 0.0)
	sewerSoundtrack.set_sync_stream_volume(1, SILENT_LAYER_DB)
	combatReleaseTimer.timeout.connect(_on_combat_release_timeout)
	EventBus.locationChanged.connect(_on_location_changed)
	EventBus.deadlineApproaching.connect(trigger_tense_music)
	EventBus.enemyCombatChanged.connect(_on_enemy_combat_changed)
	# a new day starts when the mafia debt is paid
	EventBus.debt_paid.connect(restart_music)
	# Main starts in the restaurant.
	_on_location_changed("restaurant")


func _on_location_changed(location: String) -> void:
	var nextTrack: AudioStream
	match location:
		"restaurant":
			nextTrack = RESTAURANT_MUSIC
		"sewer":
			nextTrack = sewerSoundtrack
		_:
			return
	if currentLocation != location:
		combatReleaseTimer.stop()
		_fade_combat_layer(false, true)
	currentLocation = location
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
	_refresh_combat_music()


func _on_enemy_combat_changed(_enemy: Node, _active: bool) -> void:
	_refresh_combat_music()


func _refresh_combat_music() -> void:
	if currentLocation != "sewer":
		return
	if not get_tree().get_nodes_in_group("combat_threats").is_empty():
		combatReleaseTimer.stop()
		if not combatActive:
			_fade_combat_layer(true)
	elif combatActive and combatReleaseTimer.is_stopped():
		# Brief gaps between attacks or aggro changes should not cut the drums.
		combatReleaseTimer.start(combatReleaseSeconds)


func _on_combat_release_timeout() -> void:
	if currentLocation == "sewer" and get_tree().get_nodes_in_group("combat_threats").is_empty():
		_fade_combat_layer(false)


func _fade_combat_layer(active: bool, immediately: bool = false) -> void:
	combatActive = active
	if combatTween and combatTween.is_valid():
		combatTween.kill()
	var targetVolume = combatLayerVolumeDb if active else SILENT_LAYER_DB
	if immediately:
		_set_combat_volume(targetVolume)
		return
	var duration = combatFadeInSeconds if active else combatFadeOutSeconds
	combatTween = create_tween()
	combatTween.tween_method(
		_set_combat_volume,
		sewerSoundtrack.get_sync_stream_volume(1),
		targetVolume,
		duration
	)


func _set_combat_volume(value: float) -> void:
	sewerSoundtrack.set_sync_stream_volume(1, value)


# Call this function when your clock hits the final 60 seconds
func trigger_tense_music() -> void:
	if is_tense_mode:
		return
	is_tense_mode = true

	# Smoothly pitch up the music to make it sound tense and fast-paced
	if pitchTween and pitchTween.is_valid():
		pitchTween.kill()
	pitchTween = create_tween()
	pitchTween.tween_property(self, "pitch_scale", 1.25, 1.0)


# Call this if the player pays off debt or time resets
func reset_music_pitch() -> void:
	is_tense_mode = false
	if pitchTween and pitchTween.is_valid():
		pitchTween.kill()
	pitchTween = create_tween()
	pitchTween.tween_property(self, "pitch_scale", 1.0, 1.0)

# starts the song from the beginning at normal speed (new day)
func restart_music() -> void:
	# A pending deadline tween must not speed the music up again after payment.
	if pitchTween and pitchTween.is_valid():
		pitchTween.kill()
	is_tense_mode = false
	pitch_scale = 1.0
	play(0.0)
