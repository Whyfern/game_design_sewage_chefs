extends Control

# Game over screen. Opened with GameManager.trigger_game_over("reason").

@export_file("*.tscn") var gameScenePath: String = "res://scenes/main.tscn"
@export_file("*.tscn") var menuScenePath: String = "res://scenes/menus/main_menu.tscn"
@export var fadeDuration: float = 0.5

@onready var reasonLabel: Label = %ReasonLabel
@onready var statsLabel: Label = %StatsLabel
@onready var tryAgainButton: Button = %TryAgainButton
@onready var menuButton: Button = %MenuButton
@onready var titleLabel: Label = %TitleLabel
@onready var fadeRect: ColorRect = %FadeRect

var isLeaving: bool = false


func _ready() -> void:
	reasonLabel.text = GameManager.game_over_reason
	statsLabel.text = "You made it to day %d  ·  Cheese left: €%d  ·  Debt: €%d" % [
		GameManager.current_day, GameManager.money, GameManager.mafia_debt]

	tryAgainButton.pressed.connect(_on_try_again_pressed)
	menuButton.pressed.connect(_on_menu_pressed)

	fadeRect.visible = true
	fadeRect.color.a = 1.0
	var fadeIn: Tween = create_tween()
	fadeIn.tween_property(fadeRect, "color:a", 0.0, fadeDuration)
	await fadeIn.finished
	fadeRect.visible = false
	tryAgainButton.grab_focus()


# starts a new game straight in the restaurant (day 1)
func _on_try_again_pressed() -> void:
	leave_to(gameScenePath)


# back to the main menu
func _on_menu_pressed() -> void:
	leave_to(menuScenePath)


# resets the game state, fades to black and opens the next scene
func leave_to(scenePath: String) -> void:
	if isLeaving:
		return
	isLeaving = true

	fadeRect.visible = true
	var fadeOut: Tween = create_tween()
	fadeOut.tween_property(fadeRect, "color:a", 1.0, fadeDuration)
	await fadeOut.finished

	GameManager.reset_game()
	LoadingScreen.change_to_scene(get_tree(), scenePath)
