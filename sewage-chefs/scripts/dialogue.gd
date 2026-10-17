extends CanvasLayer

signal dialogue_finished

@onready var panel: Control = %DialoguePanel
@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel

var dialog_lines: Array[Dictionary] = []
var current_line_index: int = 0
var is_typing: bool = false
var is_active: bool = false
var text_tween: Tween


func _ready() -> void:
	panel.hide()


func show_dialogue(lines: Array[Dictionary]) -> void:
	if is_active or lines.is_empty():
		return

	dialog_lines = lines
	current_line_index = 0
	is_active = true

	panel.show()
	_display_current_line()

	await dialogue_finished


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()

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
				_on_dialogue_finished()


func _display_current_line() -> void:
	var entry = dialog_lines[current_line_index]

	name_label.text = entry["name"]
	text_label.text = replace_variables(entry["text"])

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


func _on_dialogue_finished() -> void:
	is_active = false
	panel.hide()
	dialogue_finished.emit()
	
	
func replace_variables(dialogue_text: String) -> String:
	#replace the variables in dialogue to concrete (global) values
	dialogue_text = dialogue_text.replace("$money", str(GameManager.money))
	dialogue_text = dialogue_text.replace("$mafia_debt", str(GameManager.mafia_debt))
	return dialogue_text
