extends VBoxContainer

@onready var countdown_label: Label = %TimeCountdownLabel

@export var day_duration_seconds: float = 1 # 8 minutes for a full game day
var time_elapsed: float = 0.0
var is_active: bool = true
var is_pulsing: bool = false

func _ready() -> void:
	time_elapsed = 0.0

func _process(delta: float) -> void:
	if not is_active:
		return

	time_elapsed += delta
	if time_elapsed >= day_duration_seconds:
		time_elapsed = day_duration_seconds
		is_active = false
		_on_deadline_reached()

	_update_countdown_display()

func _update_countdown_display() -> void:
	var time_left: float = day_duration_seconds - time_elapsed
	var remaining_minutes: int = int(time_left) / 60
	var remaining_seconds: int = int(time_left) % 60

	if countdown_label:
		# Format strictly as the text display
		countdown_label.text = "Due: %02d:%02d" % [remaining_minutes, remaining_seconds]
		
		# Trigger red text and pulse effect during the final 60 seconds
		if time_left <= 60.0:
			countdown_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
			%Music.trigger_tense_music()
			
			if not is_pulsing:
				is_pulsing = true
				start_pulse_effect()
		else:
			countdown_label.add_theme_color_override("font_color", Color(0, 0, 0))

func start_pulse_effect() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(countdown_label, "modulate:a", 0.2, 0.3)
	tween.tween_property(countdown_label, "modulate:a", 1.0, 0.3)

func _on_deadline_reached() -> void:
	print("Time's up! Don Parmesan is here for the money.")
	EventBus.don_parmesan_spawn_requested.emit()
