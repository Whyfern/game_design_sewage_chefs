extends TextureProgressBar

@export_category("Flood warning audio")
@export_range(0.1, 120.0, 0.1) var tickWarningSeconds: float = 30.0
@export var tickStartVolumeDb: float = -30.0
@export var tickEndVolumeDb: float = -12.0
@onready var clockTickSound: AudioStreamPlayer = $ClockTickSound

# Assigned by LevelManager when it creates the sewer's actual flood timer.
var sewageMan: Node = null
var isFlooding: bool = false
var currentLocation: String = "restaurant"

func _ready() -> void:
	min_value = 0.0
	value = 0.0
	position.y -= 80.0
	visible = false
	EventBus.locationChanged.connect(_on_location_changed)

func set_parameters() -> void:
	if not is_instance_valid(sewageMan):
		return
	max_value = maxf(sewageMan.maxTime, 0.1)
	value = 0.0
	isFlooding = true
	clockTickSound.stop()
	clockTickSound.volume_db = tickStartVolumeDb

func _on_location_changed(location: String) -> void:
	if location not in ["restaurant", "sewer"] or location == currentLocation:
		return
	currentLocation = location
	if location == "sewer":
		set_parameters()
		visible = true
	else:
		stop_flood_timer()

func _process(_delta: float) -> void:
	if not isFlooding or currentLocation != "sewer":
		clockTickSound.stop()
		return
	if not is_instance_valid(sewageMan):
		stop_flood_timer()
		return
	# LevelManager uses deferred spawning, so the Timer may not be ready yet.
	if not sewageMan.is_node_ready():
		return
	var time_left: float = clampf(sewageMan.sewageTimer.time_left, 0.0, max_value)
	value = max_value - time_left
	_update_clock_warning(time_left)
	if time_left <= 0.0:
		value = max_value
		isFlooding = false
		clockTickSound.stop()

func stop_flood_timer() -> void:
	isFlooding = false
	sewageMan = null
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
	if not clockTickSound.playing:
		clockTickSound.play()
