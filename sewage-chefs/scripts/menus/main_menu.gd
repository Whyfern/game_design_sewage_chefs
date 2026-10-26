extends Control

# Main menu: Start Game, How to Play, Quit.

@export_file("*.tscn") var startScenePath: String = "res://scenes/IntroScene.tscn"
@export var fadeDuration: float = 0.5

const INSTRUCTIONS_TEXT: String = """[center][b][color=#f5c542]Your goal[/color][/b][/center]
You are Chef Ricardo, a rat with a brand-new restaurant and a loan from the mafia. Every day, before the clock runs out, you have to earn enough cheese (€) to pay [b]Don Parmesan[/b] his tribute. The first tribute is €50 and it goes up by €25 every day. Pay him one last time on [b]day 5[/b] and you are free.

[center][b][color=#f5c542]Controls[/color][/b][/center]
[b]W A S D[/b] / [b]arrow keys[/b]  -  move
[b]E[/b]  -  interact, serve, pick up, talk
[b]Left mouse[/b]  -  attack towards the cursor
[b]Q[/b]  -  drop all dishes
[b]Esc[/b]  -  skip the intro

[center][b][color=#f5c542]The restaurant[/color][/b][/center]
Customers come in and show the dish they want and its price. Walk up to them and press [b]E[/b] to serve it, if you have it. Be quick: when their patience bar runs out they leave without paying. Once the clock runs out you can't serve anymore.

[center][b][color=#f5c542]The sewer[/color][/b][/center]
Flush the toilet to go down into the sewer. Collect dishes (you can carry 8): the deeper the room, the rarer and more valuable the dishes. Rats will attack you, and standing in the sewage hurts too. Keep an eye on the flood meter. Your health is restored when you go back up to the restaurant.

[center][b][color=#f5c542]When the clock runs out[/color][/b][/center]
Don Parmesan comes to collect. Talk to him and pay up, if you can. If you refuse to pay, you have to fight his gang: beat his thugs or bribe them for €20 each. Every tribute you paid before means one thug less.

[center][b][color=#f5c542]Game over[/color][/b][/center]
If your health reaches zero, the game is over and you start again from day 1."""

@onready var mainButtons: VBoxContainer = %MainButtons
@onready var startButton: Button = %StartButton
@onready var instructionsButton: Button = %InstructionsButton
@onready var quitButton: Button = %QuitButton
@onready var instructionsPanel: PanelContainer = %InstructionsPanel
@onready var instructionsText: RichTextLabel = %InstructionsText
@onready var backButton: Button = %BackButton
@onready var titleLabel: Label = %TitleLabel
@onready var fadeRect: ColorRect = %FadeRect

var isStarting: bool = false


func _ready() -> void:
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
	var fadeIn: Tween = create_tween()
	fadeIn.tween_property(fadeRect, "color:a", 0.0, fadeDuration)
	await fadeIn.finished
	fadeRect.visible = false
	startButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if instructionsPanel.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()


# fades to black and opens the intro (which then opens the game)
func _on_start_pressed() -> void:
	if isStarting:
		return
	isStarting = true

	fadeRect.visible = true
	var fadeOut: Tween = create_tween()
	fadeOut.tween_property(fadeRect, "color:a", 1.0, fadeDuration)
	await fadeOut.finished

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
