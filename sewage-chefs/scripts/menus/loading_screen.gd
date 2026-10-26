extends Control
class_name LoadingScreen

# First screen of the game. Loads the heavy scenes in the background
# (with a real progress bar), then opens the main menu.

# scene that opens when loading is finished
@export_file("*.tscn") var nextScenePath: String = "res://scenes/menus/main_menu.tscn"
# scenes that are loaded in the background so starting the game is fast later
@export var scenesToPreload: Array[String] = [
	"res://scenes/main.tscn",
	"res://scenes/IntroScene.tscn",
]
# the screen stays at least this long, so it doesn't just flash by
@export var minimumDuration: float = 2.5
@export var fadeDuration: float = 0.5

# Loaded scenes are kept here so Godot keeps them in memory.
# The menu uses this to start the game without loading again.
static var preloadedScenes: Dictionary = {}

# one of these is shown at random at the bottom of the screen
const TIPS: Array[String] = [
	"Tip: the deeper the sewer room, the rarer the ingredients.",
	"Tip: Don Parmesan doesn't accept crumbs. Save up before the clock runs out.",
	"Tip: switch weapons with 1, 2, 3 or the mouse wheel.",
	"Tip: keep an eye on the flood meter when you are in the sewer.",
	"Tip: you can carry up to 5 ingredients at once.",
]

@onready var progressBar: ProgressBar = %ProgressBar
@onready var statusLabel: Label = %StatusLabel
@onready var tipLabel: Label = %TipLabel
@onready var ratIcon: TextureRect = %RatIcon
@onready var fadeRect: ColorRect = %FadeRect

# every scene that is being loaded (scenesToPreload + nextScenePath)
var allPaths: Array[String] = []
# seconds since the loading screen opened
var elapsedTime: float = 0.0
# progress that the bar currently shows (0 - 1), moves smoothly towards the real progress
var shownProgress: float = 0.0
# true once loading is done, so finish_loading() only runs once
var isFinishing: bool = false


func _ready() -> void:
	# pick a random tip and start with an empty bar
	tipLabel.text = TIPS.pick_random()
	progressBar.value = 0.0

	# the next scene (the menu) is loaded too
	allPaths.assign(scenesToPreload)
	if not allPaths.has(nextScenePath):
		allPaths.append(nextScenePath)

	# start loading every scene on a background thread, so the screen keeps animating
	for scenePath in allPaths:
		if ResourceLoader.exists(scenePath):
			ResourceLoader.load_threaded_request(scenePath)
		else:
			push_warning("LoadingScreen: scene not found: " + scenePath)

	# fade in from black
	fadeRect.visible = true
	fadeRect.color.a = 1.0
	create_tween().tween_property(fadeRect, "color:a", 0.0, fadeDuration)


func _process(delta: float) -> void:
	if isFinishing:
		return

	elapsedTime += delta

	# real loading progress (0 - 1), averaged over all scenes
	var realProgress: float = get_real_progress()
	# the bar can't go faster than the minimum duration allows
	var timeProgress: float = clamp(elapsedTime / minimumDuration, 0.0, 1.0)
	var targetProgress: float = min(realProgress, timeProgress)

	# move the bar smoothly instead of jumping
	shownProgress = move_toward(shownProgress, targetProgress, delta * 1.5)
	progressBar.value = shownProgress * 100.0
	statusLabel.text = "Loading... %d%%" % int(shownProgress * 100.0)

	# everything loaded and the bar is full -> go to the next scene
	if realProgress >= 1.0 and shownProgress >= 1.0:
		finish_loading()


# asks Godot how far each background load is and returns the average (0 - 1)
func get_real_progress() -> float:
	if allPaths.is_empty():
		return 1.0

	var total: float = 0.0
	for scenePath in allPaths:
		# Godot writes the progress of this scene (0 - 1) into progressArray[0]
		var progressArray: Array = []
		var status = ResourceLoader.load_threaded_get_status(scenePath, progressArray)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED, ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# failed or missing scenes count as done so the game never gets stuck here
				total += 1.0
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				total += progressArray[0] if not progressArray.is_empty() else 0.0
	return total / allPaths.size()


# stores the loaded scenes and opens the next scene (the main menu)
func finish_loading() -> void:
	isFinishing = true
	statusLabel.text = "Ready!"

	# take the finished scenes from the loader and keep them in preloadedScenes
	for scenePath in allPaths:
		if ResourceLoader.load_threaded_get_status(scenePath) == ResourceLoader.THREAD_LOAD_LOADED:
			preloadedScenes[scenePath] = ResourceLoader.load_threaded_get(scenePath)

	# short pause on 100%, then fade to black and open the menu
	await get_tree().create_timer(0.3).timeout
	var fadeOut: Tween = create_tween()
	fadeOut.tween_property(fadeRect, "color:a", 1.0, fadeDuration)
	await fadeOut.finished

	# use the preloaded menu if possible, otherwise load it the normal way
	var nextScene: PackedScene = preloadedScenes.get(nextScenePath)
	if nextScene:
		get_tree().change_scene_to_packed(nextScene)
	else:
		get_tree().change_scene_to_file(nextScenePath)




# Helper for other scenes (used by the main menu): changes to a scene and uses the
# version that was preloaded on the loading screen if there is one, which is faster.
static func change_to_scene(tree: SceneTree, scenePath: String) -> void:
	var packed: PackedScene = preloadedScenes.get(scenePath)
	if packed:
		tree.change_scene_to_packed(packed)
	else:
		tree.change_scene_to_file(scenePath)
