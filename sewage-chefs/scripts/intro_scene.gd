extends Node2D

@export_file("*.tscn") var restaurant_scene_path: String = "res://scenes/Restaurant.tscn"

# Drag your portraits into the Inspector on the right
@export var chef_portrait: Texture2D
@export var don_portrait: Texture2D

# Adjust these node paths to match your DialogueBox nodes
@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel

var dialog_lines: Array[Dictionary] = []
var current_line_index: int = 0
var is_typing: bool = false
var text_tween: Tween

func _ready() -> void:
	dialog_lines = [
		{
			"name": "Chef Pip",
			"portrait": chef_portrait,
			"text": "Finally... Uncle Roquefort's dream is mine! Sure, the drain pipes leak toxic sludge, but you can't buy this kind of ambiance."
		},
		{
			"name": "Chef Pip",
			"portrait": chef_portrait,
			"text": "Well, actually... I couldn't buy it at all. The bank laughed me out of the burrow, so I took a little loan from... underground gentlemen. But hey, how bad could the interest be?"
		},
		{
			"name": "Don Parmesan",
			"portrait": don_portrait,
			"text": "Dangerously bad, kid. In my business, time is cheddar."
		},
		{
			"name": "Don Parmesan",
			"portrait": don_portrait,
			"text": "Remember your weekly tribute: [b][color=yellow]€50[/color][/b]. If that clock runs out and my palms aren't greased, you get [b][color=red]brie-headed[/color][/b]. Pay up or get grated."
		}
	]

	_display_current_line()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		if is_typing:
			if text_tween:
				text_tween.kill()
			text_label.visible_ratio = 1.0
			is_typing = false
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
	
	if entry["portrait"] != null:
		portrait.texture = entry["portrait"]
		portrait.visible = true
	else:
		portrait.visible = false

	text_label.visible_ratio = 0.0
	is_typing = true
	
	var char_count: int = text_label.get_parsed_text().length()
	var duration: float = float(char_count) * 0.025
	
	if text_tween:
		text_tween.kill()
		
	text_tween = create_tween()
	text_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	text_tween.finished.connect(func(): is_typing = false)

func _on_intro_finished() -> void:
	EventBus.intro_dialogue_finished.emit()
	
	if restaurant_scene_path != "":
		get_tree().change_scene_to_file("res://scenes/main.tscn")
