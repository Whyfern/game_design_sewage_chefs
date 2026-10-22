extends Node2D

# Scene that is loaded once the intro is finished
@export_file("*.tscn") var next_scene_path: String = "res://scenes/main.tscn"

# Drag your portraits into the Inspector on the right
@export var chef_portrait: Texture2D
@export var don_portrait: Texture2D

@export_category("Timing")
@export var seconds_per_character: float = 0.025
@export var fade_duration: float = 0.8

# colour of the portrait of the character that is NOT talking
const INACTIVE_PORTRAIT_COLOR: Color = Color(0.4, 0.4, 0.4, 1.0)
const ACTIVE_PORTRAIT_COLOR: Color = Color(1, 1, 1, 1)

# Chef is shown on the left (%Portrait), the Don on the right (%DonPortrait)
@onready var portrait: TextureRect = %Portrait
@onready var don_portrait_rect: TextureRect = %DonPortrait
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var continue_label: Label = %ContinueLabel
@onready var fade_rect: ColorRect = %FadeRect

var dialog_lines: Array[Dictionary] = []
var current_line_index: int = 0
var is_typing: bool = false
var is_transitioning: bool = true # blocks input while fading in/out
var text_tween: Tween
var continue_tween: Tween

func _ready() -> void:
	dialog_lines = [
		{
			"name": "Chef Ricardo",
			"speaker": "chef",
			"text": "Finally... Uncle Roquefort's dream is mine! Sure, the drain pipes leak toxic sludge, but you can't buy this kind of ambiance."
		},
		{
			"name": "Chef Ricardo",
			"speaker": "chef",
			"text": "Well, actually... I couldn't buy it at all. The bank laughed me out of the burrow, so I took a little loan from... underground gentlemen. But hey, how bad could the interest be?"
		},
		{
			"name": "Don Parmesan",
			"speaker": "don",
			"text": "Dangerously bad, kid. In my business, time is cheddar."
		},
		{
			"name": "Don Parmesan",
			"speaker": "don",
			"text": "Remember your weekly tribute: €50. If that clock runs out and my palms aren't greased, you get brie-headed. Pay up or get grated."
		}
	]

	# set up portraits: both hidden until their character speaks for the first time
	portrait.texture = chef_portrait
	don_portrait_rect.texture = don_portrait
	portrait.modulate.a = 0.0
	don_portrait_rect.modulate.a = 0.0

	continue_label.visible = false
	name_label.text = ""
	text_label.text = ""

	# fade in from black, then start the first line
	fade_rect.visible = true
	fade_rect.color.a = 1.0
	var fade_in: Tween = create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, fade_duration)
	await fade_in.finished
	fade_rect.visible = false
	is_transitioning = false

	_display_current_line()

func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning:
		return

	# Esc skips the whole intro
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_intro_finished()
		return

	var advance_pressed: bool = event.is_action_pressed("ui_accept") \
		or event.is_action_pressed("interact") \
		or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)

	if not advance_pressed:
		return

	get_viewport().set_input_as_handled()

	if is_typing:
		# first press finishes the line instantly
		if text_tween:
			text_tween.kill()
		_on_line_finished_typing()
	else:
		current_line_index += 1
		if current_line_index < dialog_lines.size():
			_display_current_line()
		else:
			_on_intro_finished()

func _display_current_line() -> void:
	var entry = dialog_lines[current_line_index]

	name_label.text = entry["name"]
	text_label.text = entry["text"]

	_update_portraits(entry["speaker"])

	_stop_continue_blink()
	text_label.visible_ratio = 0.0
	is_typing = true

	var char_count: int = text_label.get_parsed_text().length()
	var duration: float = float(char_count) * seconds_per_character

	if text_tween:
		text_tween.kill()

	text_tween = create_tween()
	text_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	text_tween.finished.connect(_on_line_finished_typing)

# highlights the speaking character and dims the other one
func _update_portraits(speaker: String) -> void:
	var speaking_rect: TextureRect = portrait if speaker == "chef" else don_portrait_rect
	var listening_rect: TextureRect = don_portrait_rect if speaker == "chef" else portrait

	var tween: Tween = create_tween().set_parallel(true)
	var speaking_color: Color = ACTIVE_PORTRAIT_COLOR
	tween.tween_property(speaking_rect, "modulate", speaking_color, 0.25)

	# only dim the other character if they have already appeared
	if listening_rect.modulate.a > 0.0:
		tween.tween_property(listening_rect, "modulate", INACTIVE_PORTRAIT_COLOR, 0.25)

func _on_line_finished_typing() -> void:
	text_label.visible_ratio = 1.0
	is_typing = false
	_start_continue_blink()

# blinking "continue" hint once a line is fully shown
func _start_continue_blink() -> void:
	continue_label.visible = true
	continue_label.modulate.a = 1.0
	if continue_tween:
		continue_tween.kill()
	continue_tween = create_tween().set_loops()
	continue_tween.tween_property(continue_label, "modulate:a", 0.2, 0.5)
	continue_tween.tween_property(continue_label, "modulate:a", 1.0, 0.5)

func _stop_continue_blink() -> void:
	if continue_tween:
		continue_tween.kill()
	continue_label.visible = false

func _on_intro_finished() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	_stop_continue_blink()
	if text_tween:
		text_tween.kill()

	EventBus.intro_dialogue_finished.emit()

	# fade to black, then load the game
	fade_rect.visible = true
	var fade_out: Tween = create_tween()
	fade_out.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	await fade_out.finished

	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
