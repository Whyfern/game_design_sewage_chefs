extends TextureProgressBar

@export_range(0.1, 3600.0, 0.1) var fill_duration: float = 120.0
@export_category("Flood warning audio")
@export_range(0.1, 120.0, 0.1) var tickWarningSeconds: float = 30.0
@export var tickStartVolumeDb: float = -30.0
@export var tickEndVolumeDb: float = -12.0

@onready var clockTickSound: AudioStreamPlayer = $ClockTickSound

var time_elapsed: float = 0.0
var is_flooding: bool = false
var currentLocation: String = "restaurant"

func _ready() -> void:
	# Configure the progress bar range from 0 to 100
	min_value = 0.0
	max_value = 100.0
	value = 0.0 
	
	# Hide the progress bar when the game starts
	visible = false

	# Start after sewer entry completes, rather than on every toilet flush.
	EventBus.locationChanged.connect(_on_location_changed)


func _on_location_changed(location: String) -> void:
	if location not in ["restaurant", "sewer"] or location == currentLocation:
		return
	currentLocation = location
	if location == "sewer":
		start_flood_timer()
	else:
		stop_flood_timer()

func _process(delta: float) -> void:
	if not is_flooding:
		clockTickSound.stop()
		return

	# Accumulate time
	time_elapsed = minf(time_elapsed + delta, fill_duration)
	value = (time_elapsed / fill_duration) * 100.0
	var time_left: float = maxf(fill_duration - time_elapsed, 0.0)
	_update_clock_warning(time_left)

	# Check if it reached 100%
	if time_elapsed >= fill_duration:
		value = 100.0
		is_flooding = false
		_on_sewer_flooded()

func start_flood_timer() -> void:
	clockTickSound.stop()
	clockTickSound.volume_db = tickStartVolumeDb
	time_elapsed = 0.0
	value = 0.0
	is_flooding = true
	
	# Show the meter only during a sewer visit.
	visible = true
	print("Entered sewer! Flooding timer started.")


func stop_flood_timer() -> void:
	is_flooding = false
	time_elapsed = 0.0
	value = 0.0
	visible = false
	clockTickSound.stop()
	clockTickSound.volume_db = tickStartVolumeDb


func _update_clock_warning(time_left: float) -> void:
	if time_left > tickWarningSeconds or time_left <= 0.0:
		clockTickSound.stop()
		return
	var progress: float = clampf(1.0 - time_left / tickWarningSeconds, 0.0, 1.0)
	clockTickSound.volume_db = lerpf(tickStartVolumeDb, tickEndVolumeDb, progress)
	# Keep one continuous recording playing while its volume changes.
	if not clockTickSound.playing:
		clockTickSound.play()

func _on_sewer_flooded() -> void:
	clockTickSound.stop()
	print("The sewer is fully flooded!")
