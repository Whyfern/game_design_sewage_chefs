extends Control
class_name LoadingScreen

# First screen of the game, loads the heavy scenes in the background

@export_file("*.tscn") var nextScenePath: String = "res://scenes/menus/main_menu.tscn"
@export var scenesToPreload: Array[String] = [
	"res://scenes/main.tscn",
	"res://scenes/IntroScene.tscn",
]
@export var minimumDuration: float = 2.5
@export var fadeDuration: float = 0.5

static var preloadedScenes: Dictionary = {}

const TIPS: Array[String] = [
	"Tip: the deeper the sewer room, the rarer the ingredients.",
	"Tip: Don Parmesan doesn't accept crumbs. Save up before the clock runs out.",
	"Tip: press Q to drop all your dishes when your inventory is full.",
	"Tip: keep an eye on the flood meter when you are in the sewer.",
	"Tip: you can carry up to 8 ingredients at once.",
]

@onready var progressBar: ProgressBar = %ProgressBar
@onready var statusLabel: Label = %StatusLabel
@onready var tipLabel: Label = %TipLabel
@onready var ratIcon: TextureRect = %RatIcon
@onready var fadeRect: ColorRect = %FadeRect

var allPaths: Array[String] = []
var elapsedTime: float = 0.0
var shownProgress: float = 0.0
var isFinishing: bool = false


func _ready() -> void:
	tipLabel.text = TIPS.pick_random()
	progressBar.value = 0.0

	allPaths.assign(scenesToPreload)
	if not allPaths.has(nextScenePath):
		allPaths.append(nextScenePath)

	for scenePath in allPaths:
		if ResourceLoader.exists(scenePath):
			ResourceLoader.load_threaded_request(scenePath)
		else:
			push_warning("LoadingScreen: scene not found: " + scenePath)

	fadeRect.visible = true
	fadeRect.color.a = 1.0
	create_tween().tween_property(fadeRect, "color:a", 0.0, fadeDuration)


func _process(delta: float) -> void:
	if isFinishing:
		return

	elapsedTime += delta

	var realProgress: float = get_real_progress()
	var timeProgress: float = clamp(elapsedTime / minimumDuration, 0.0, 1.0)
	var targetProgress: float = min(realProgress, timeProgress)

	shownProgress = move_toward(shownProgress, targetProgress, delta * 1.5)
	progressBar.value = shownProgress * 100.0
	statusLabel.text = "Loading... %d%%" % int(shownProgress * 100.0)

	if realProgress >= 1.0 and shownProgress >= 1.0:
		finish_loading()


# asks Godot how far each background load is and returns the average (0 - 1)
func get_real_progress() -> float:
	if allPaths.is_empty():
		return 1.0

	var total: float = 0.0
	for scenePath in allPaths:
		var progressArray: Array = []
		var status = ResourceLoader.load_threaded_get_status(scenePath, progressArray)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED, ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				total += 1.0
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				total += progressArray[0] if not progressArray.is_empty() else 0.0
	return total / allPaths.size()


# stores the loaded scenes and opens the next scene (the main menu)
func finish_loading() -> void:
	isFinishing = true
	statusLabel.text = "Ready!"

	for scenePath in allPaths:
		if ResourceLoader.load_threaded_get_status(scenePath) == ResourceLoader.THREAD_LOAD_LOADED:
			preloadedScenes[scenePath] = ResourceLoader.load_threaded_get(scenePath)

	await get_tree().create_timer(0.3).timeout
	var fadeOut: Tween = create_tween()
	fadeOut.tween_property(fadeRect, "color:a", 1.0, fadeDuration)
	await fadeOut.finished

	var nextScene: PackedScene = preloadedScenes.get(nextScenePath)
	if nextScene:
		get_tree().change_scene_to_packed(nextScene)
	else:
		get_tree().change_scene_to_file(nextScenePath)


# changes scene, using the preloaded version if there is one
static func change_to_scene(tree: SceneTree, scenePath: String) -> void:
	var packed: PackedScene = preloadedScenes.get(scenePath)
	if packed:
		tree.change_scene_to_packed(packed)
	else:
		tree.change_scene_to_file(scenePath)
