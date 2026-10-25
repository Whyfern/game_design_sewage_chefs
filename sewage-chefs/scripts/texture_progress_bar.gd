extends TextureProgressBar

@export var fill_duration: float = 120.0 # 2 minutes in seconds
@onready var sewageBar: TextureProgressBar = get_node("/root/Main/CanvasLayer/TextureProgressBar")
var sewageMan : Node = null
var time_elapsed: float = 0.0
var isFlooding: bool = false

func _ready() -> void:
	# Configure the progress bar range from 0 to 100
	min_value = 0.0
	max_value = 100.0
	value = 0.0 
	sewageBar.position.y -= 80
	
	# Hide the progress bar when the game starts
	visible = false

	# Listen for the toilet flush signal globally from the EventBus
	#if EventBus.has_signal("toiletFlushed"):
		#EventBus.toiletFlushed.connect(start_flood_timer)

func set_parameters():
	max_value = sewageMan.maxTime
	isFlooding = true
	pass

func _process(delta: float) -> void:
	if isFlooding:
		value = max_value - sewageMan.sewageTimer.time_left
	pass

#func _process(delta: float) -> void:
	#if not is_flooding:
		#return
#
	## Accumulate time
	#time_elapsed += delta
	#value = (time_elapsed / fill_duration) * 100.0
#
	## Check if it reached 100%
	#if time_elapsed >= fill_duration:
		#value = 100.0
		#is_flooding = false
		#_on_sewer_flooded()
#
#func start_flood_timer() -> void:
	#time_elapsed = 0.0
	#value = 0.0
	#is_flooding = true
	#
	## Make the progress bar visible the moment the toilet is flushed!
	#visible = true
	#print("Toilet flushed! Sewer flooding timer started.")
#
#func _on_sewer_flooded() -> void:
	#print("The sewer is fully flooded!")
