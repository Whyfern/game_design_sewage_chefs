extends Control

# Main menu: Start Game, How to Play, Quit.

@export_file("*.tscn") var startScenePath: String = "res://scenes/IntroScene.tscn"
@export var fadeDuration: float = 0.5

@export_category("Menu music")
@export_range(-40.0, 0.0, 0.5) var musicVolumeDb: float = -12.0
@export_range(0.1, 5.0, 0.1) var musicFadeInSeconds: float = 1.5
@export_range(0.1, 5.0, 0.1) var musicFadeOutSeconds: float = 0.5

const INSTRUCTIONS_TEXT: String = """[center][b][color=#f5c542]Your goal[/color][/b][/center]
You are Chef Ricardo, a rat with a brand-new restaurant and a loan from the mafia. Before the clock runs out you have to earn enough cheese (€) to pay [b]Don Parmesan[/b] his tribute. Every time you pay, the tribute goes up by €25.

[center][b][color=#f5c542]Controls[/color][/b][/center]
[b]W A S D[/b] / [b]arrow keys[/b]  -  move
[b]E[/b]  -  interact, pick up, talk
[b]Left mouse[/b]  -  attack towards the cursor
[b]1 / 2 / 3[/b] or [b]mouse wheel[/b]  -  switch weapon
[b]Esc[/b]  -  skip the intro

[center][b][color=#f5c542]The restaurant[/color][/b][/center]
Customers come in and show what they want to eat. Serve the requested dish and earn money.

[center][b][color=#f5c542]The sewer[/color][/b][/center]
Flush the toilet to go down into the sewer. Collect dishes (you can carry 5): the deeper the room, the rarer the dishes. Watch out for rats and keep an eye on the flood meter...

[center][b][color=#f5c542]When the clock runs out[/color][/b][/center]
Don Parmesan comes to collect. Talk to him and pay up, if you can."""

@onready var mainButtons: VBoxContainer = %MainButtons
@onready var startButton: Button = %StartButton
@onready var instructionsButton: Button = %InstructionsButton
@onready var quitButton: Button = %QuitButton
@onready var instructionsPanel: PanelContainer = %InstructionsPanel
@onready var instructionsText: RichTextLabel = %InstructionsText
@onready var backButton: Button = %BackButton
@onready var titleLabel: Label = %TitleLabel
@onready var fadeRect: ColorRect = %FadeRect
@onready var menuMusic: AudioStreamPlayer = $MenuMusic

var isStarting: bool = false
var musicTween: Tween
var screenFadeTween: Tween


func _ready() -> void:
	_start_menu_music()
	instructionsText.text = INSTRUCTIONS_TEXT
	instructionsPanel.visible = false

	startButton.pressed.connect(_on_start_pressed)
	instructionsButton.pressed.connect(_on_instructions_pressed)
	quitButton.pressed.connect(_on_quit_pressed)
	backButton.pressed.connect(_on_back_pressed)

	if OS.has_feature("web"):
		quitButton.visible = false

	fadeRect.visible = true
	fadeRect.color.a = 1.0
	screenFadeTween = create_tween()
	screenFadeTween.tween_property(fadeRect, "color:a", 0.0, fadeDuration)
	await screenFadeTween.finished
	fadeRect.visible = false
	startButton.grab_focus()


func _start_menu_music() -> void:
	# Fade amplitude from complete silence, keeping the same playback running afterward.
	menuMusic.volume_linear = 0.0
	menuMusic.play()
	musicTween = create_tween()
	musicTween.tween_property(
		menuMusic, "volume_linear", db_to_linear(musicVolumeDb), musicFadeInSeconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _unhandled_input(event: InputEvent) -> void:
	if instructionsPanel.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()


# fades to black and opens the intro (which then opens the game)
func _on_start_pressed() -> void:
	if isStarting:
		return
	isStarting = true

	# Starting quickly must cancel either fade-in before the fade-out takes control.
	if musicTween and musicTween.is_valid():
		musicTween.kill()
	if screenFadeTween and screenFadeTween.is_valid():
		screenFadeTween.kill()
	fadeRect.visible = true
	var fadeOut: Tween = create_tween().set_parallel(true)
	fadeOut.tween_property(fadeRect, "color:a", 1.0, fadeDuration)
	fadeOut.tween_property(
		menuMusic, "volume_linear", 0.0, musicFadeOutSeconds
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fadeOut.finished
	menuMusic.stop()

	LoadingScreen.change_to_scene(get_tree(), startScenePath)


# hides the buttons and shows the "How to Play" panel
func _on_instructions_pressed() -> void:
	mainButtons.visible = false
	instructionsPanel.visible = true
	instructionsText.scroll_to_line(0)
	backButton.grab_focus()


# closes the "How to Play" panel and shows the buttons again
func _on_back_pressed() -> void:
	instructionsPanel.visible = false
	mainButtons.visible = true
	instructionsButton.grab_focus()


# closes the game
func _on_quit_pressed() -> void:
	get_tree().quit()
