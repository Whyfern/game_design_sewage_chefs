extends CanvasLayer

# Autoload "LevelTransition": black screen between the restaurant and the sewer

@export var minimumDuration: float = 1.2
@export var fadeDuration: float = 0.35
@export var maxWaitTime: float = 10.0

const TO_SEWER_TEXTS: Array[String] = [
	"Down the drain...",
	"Holding your breath...",
	"Into the sewer...",
]
const TO_RESTAURANT_TEXTS: Array[String] = [
	"Back to the restaurant...",
	"Climbing out of the pipes...",
	"Fresh air at last...",
]

@onready var blackRect: ColorRect = %BlackRect
@onready var messageLabel: Label = %MessageLabel
@onready var chefIcon: TextureRect = %ChefIcon

var isTransitioning: bool = false
var levelReady: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_screen()

	EventBus.toiletFlushed.connect(_on_toilet_flushed)
	EventBus.startRoomPos.connect(_on_sewer_ready)


func _on_toilet_flushed() -> void:
	if isTransitioning:
		return
	play_transition(is_going_to_sewer())


# asks the level manager where the player is right now (before it switches)
func is_going_to_sewer() -> bool:
	var currentScene: Node = get_tree().current_scene
	if currentScene == null:
		return true
	var levelManager: Node = currentScene.get_node_or_null("level_manager")
	if levelManager != null and "restaurantState" in levelManager:
		return levelManager.restaurantState
	return true


func play_transition(goingToSewer: bool) -> void:
	isTransitioning = true
	levelReady = not goingToSewer

	messageLabel.text = (TO_SEWER_TEXTS if goingToSewer else TO_RESTAURANT_TEXTS).pick_random()

	var wasPaused: bool = get_tree().paused
	get_tree().paused = true

	show_screen()
	var fadeIn: Tween = create_tween()
	fadeIn.tween_property(blackRect, "modulate:a", 1.0, fadeDuration)
	await fadeIn.finished

	var waited: float = 0.0
	while (waited < minimumDuration or not levelReady) and waited < maxWaitTime:
		await get_tree().process_frame
		waited += get_process_delta_time()

	await get_tree().process_frame

	get_tree().paused = wasPaused

	var fadeOut: Tween = create_tween()
	fadeOut.tween_property(blackRect, "modulate:a", 0.0, fadeDuration)
	await fadeOut.finished

	hide_screen()
	isTransitioning = false


func _on_sewer_ready() -> void:
	levelReady = true


func show_screen() -> void:
	blackRect.visible = true
	blackRect.modulate.a = 0.0


func hide_screen() -> void:
	blackRect.visible = false


# fades to black with a message (used by the final fight)
func cover(text: String) -> void:
	isTransitioning = true
	messageLabel.text = text
	get_tree().paused = true
	show_screen()
	var fadeIn: Tween = create_tween()
	fadeIn.tween_property(blackRect, "modulate:a", 1.0, fadeDuration)
	await fadeIn.finished


# ends cover(): unpauses and fades back in
func uncover(waitTime: float = minimumDuration) -> void:
	await get_tree().create_timer(waitTime, true).timeout
	get_tree().paused = false
	var fadeOut: Tween = create_tween()
	fadeOut.tween_property(blackRect, "modulate:a", 0.0, fadeDuration)
	await fadeOut.finished
	hide_screen()
	isTransitioning = false


# used by GameManager when a new game starts, in case a transition was still playing
func cancel() -> void:
	isTransitioning = false
	hide_screen()
