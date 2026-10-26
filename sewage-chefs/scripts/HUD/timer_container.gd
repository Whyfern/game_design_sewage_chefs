extends VBoxContainer

# The autoload owns the day clock; the HUD instance only displays that clock.
@onready var countdown_label: Label = get_node_or_null("%TimeCountdownLabel")
@export var day_duration_seconds: float = 300.0
var time_elapsed: float = 0.0
var is_active: bool = true
var is_pulsing: bool = false
var pulse_tween: Tween
var is_day_clock: bool = false

func _ready() -> void:
	is_day_clock = self == get_node("/root/TimerContainer")
	EventBus.debt_paid.connect(reset_day)
	_update_countdown_display()

func _process(delta: float) -> void:
	if not is_day_clock:
		# Paying debt or starting a new game can reset the persistent clock.
		if TimerContainer.time_elapsed < time_elapsed:
			reset_day()
		time_elapsed = TimerContainer.time_elapsed
		day_duration_seconds = TimerContainer.day_duration_seconds
		is_active = TimerContainer.is_active
		_update_countdown_display()
		return

	# Menus/loading screens have no player and should not consume the game day.
	if not is_active or get_tree().get_first_node_in_group("player") == null:
		return
	time_elapsed = minf(time_elapsed + delta, day_duration_seconds)
	if time_elapsed >= day_duration_seconds:
		is_active = false
		_on_deadline_reached()
	_update_countdown_display()

func _update_countdown_display() -> void:
	var time_left: float = maxf(day_duration_seconds - time_elapsed, 0.0)
	var remaining_minutes: int = int(time_left) / 60
	var remaining_seconds: int = int(time_left) % 60
	if countdown_label:
		countdown_label.text = "Due: %02d:%02d" % [remaining_minutes, remaining_seconds]
		countdown_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2) if time_left <= 60.0 else Color.BLACK)
	if time_left <= 60.0 and not is_pulsing:
		is_pulsing = true
		if is_day_clock:
			EventBus.deadlineApproaching.emit()
		if countdown_label:
			start_pulse_effect()

func start_pulse_effect() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(countdown_label, "modulate:a", 0.2, 0.3)
	pulse_tween.tween_property(countdown_label, "modulate:a", 1.0, 0.3)

func _on_deadline_reached() -> void:
	if not is_day_clock:
		return
	GameManager.time_is_up = true
	EventBus.don_parmesan_spawn_requested.emit()

func reset_day() -> void:
	time_elapsed = 0.0
	is_active = true
	is_pulsing = false
	if is_day_clock:
		GameManager.time_is_up = false
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	if countdown_label:
		countdown_label.modulate.a = 1.0
	_update_countdown_display()
