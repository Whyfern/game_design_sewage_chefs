extends CanvasLayer

# Autoload "LevelTransition": black screen with a message that covers the switch
# between the restaurant and the sewer (when the toilet is flushed).
# It listens to the EventBus by itself, so level_manager.gd does not need to call it.
#
# Going down: stays until the sewer has finished generating (EventBus.startRoomPos).
# Going up:   there is no "done" signal, so it just stays for minimumDuration.
# The game is paused while the screen is black, so timers don't run.

@export var minimumDuration: float = 1.2
@export var fadeDuration: float = 0.35
# safety limit, so the screen never stays black forever if a signal never comes
@export var maxWaitTime: float = 10.0

# one of these is picked at random for each trip
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

# true while a transition is playing, so a second flush is ignored
var isTransitioning: bool = false
# true once the new level is ready to be shown
var levelReady: bool = false


func _ready() -> void:
	# keep running while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_screen()

	# the autoload is ready before the game scene, so this runs before
	# level_manager.switch_level() and can still see where the player is
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
		# restaurantState is true while the player is still in the restaurant
		return levelManager.restaurantState
	return true


func play_transition(goingToSewer: bool) -> void:
	isTransitioning = true
	# the restaurant has no "done" signal, so it counts as ready right away
	levelReady = not goingToSewer

	messageLabel.text = (TO_SEWER_TEXTS if goingToSewer else TO_RESTAURANT_TEXTS).pick_random()

	# pause the game so the player can't move and timers don't run
	var wasPaused: bool = get_tree().paused
	get_tree().paused = true

	# fade to black
	show_screen()
	var fadeIn: Tween = create_tween()
	fadeIn.tween_property(blackRect, "modulate:a", 1.0, fadeDuration)
	await fadeIn.finished

	# wait until the level is ready and the minimum time has passed
	var waited: float = 0.0
	while (waited < minimumDuration or not levelReady) and waited < maxWaitTime:
		await get_tree().process_frame
		waited += get_process_delta_time()

	# give the new level one more frame to finish placing everything
	await get_tree().process_frame

	get_tree().paused = wasPaused

	# fade back in to the game
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


# Used by the final fight: fades to black with a message and keeps the screen black
# (game paused) until uncover() is called. Use with await.
func cover(text: String) -> void:
	isTransitioning = true
	messageLabel.text = text
	get_tree().paused = true
	show_screen()
	var fadeIn: Tween = create_tween()
	fadeIn.tween_property(blackRect, "modulate:a", 1.0, fadeDuration)
	await fadeIn.finished


# Ends cover(): waits a moment so the message can be read, unpauses and fades out.
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
