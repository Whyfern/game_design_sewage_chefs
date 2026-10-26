extends Node2D

# The final fight against Don Parmesan's gang, built from sewer room 00.
# The Don can't be hurt. His thugs can be fought or bribed (press E).
# When the last thug is gone, the Don gives up and the player wins.
#
# Start it from anywhere with:
#   BossArena.start_fight(get_tree())
class_name BossArena

const ARENA_SCENE_PATH: String = "res://scenes/final_fight/boss_arena.tscn"
const THUG_SCENE: PackedScene = preload("res://scenes/final_fight/thug.tscn")
# the same screen as the Don's payment dialogue, used for his last lines
const DON_DIALOGUE_SCENE: PackedScene = preload("res://scenes/debt_dialogue.tscn")
# far away from the restaurant and the sewer, lined up with the 1280x704 room grid
const ARENA_POSITION: Vector2 = Vector2(-12800, -7040)

@export var donPortrait: Texture2D = preload("res://sprites/Rats/MafiaRat.PNG")

@onready var floorRoom: Node2D = $Floor
@onready var playerStart: Marker2D = $PlayerStart
@onready var thugSpawns: Node2D = $ThugSpawns
@onready var gangLabel: Label = %GangLabel
@onready var arenaCamera: Camera2D = $ArenaCamera

# number of thugs still in the arena
var thugsLeft: int = 0
var fightOver: bool = false


# Fades to black, builds the arena, moves the player into it and fades back in.
static func start_fight(tree: SceneTree) -> void:
	await LevelTransition.cover("Then we do this the old-fashioned way...")

	var arena: Node2D = load(ARENA_SCENE_PATH).instantiate()
	arena.position = ARENA_POSITION
	tree.current_scene.add_child(arena)

	var player: Node2D = tree.get_first_node_in_group("player")
	if player != null:
		player.global_position = arena.get_node("PlayerStart").global_position

	# the Don in the restaurant walks away, he is waiting in the arena now
	EventBus.don_parmesan_leave_requested.emit()

	await LevelTransition.uncover()


func _ready() -> void:
	# room 00 has its own rat in it, the arena only uses the Don's thugs
	for node in floorRoom.find_children("*", "CharacterBody2D", true, false):
		node.queue_free()
	# the player's camera has limits that keep it in the restaurant/sewer area,
	# so the arena uses its own camera that shows the whole room
	arenaCamera.make_current()
	spawn_thugs()


# spawns the thugs on the spawn markers (5 minus one per tribute paid, at least 1)
func spawn_thugs() -> void:
	var markers: Array[Node] = thugSpawns.get_children()
	var count: int = GameManager.get_thug_count()
	for i in count:
		var thug: Node2D = THUG_SCENE.instantiate()
		thug.position = markers[i % markers.size()].position
		add_child(thug)
		thug.gone.connect(_on_thug_gone)
	thugsLeft = count
	update_gang_label()


func _on_thug_gone(_thug: Node, _how: String) -> void:
	thugsLeft -= 1
	update_gang_label()
	if thugsLeft <= 0:
		end_fight()


func update_gang_label() -> void:
	gangLabel.text = "Don Parmesan's gang: %d left\nBribe a thug: €%d (press E)" % [
		thugsLeft, GameManager.BRIBE_PRICE]


# the Don gives up, then the victory screen opens
func end_fight() -> void:
	if fightOver:
		return
	fightOver = true
	gangLabel.text = "The gang is gone!"

	# The player's interaction system reacts to E before the dialogue does, and it
	# takes the key as long as anything is left in its list. Switch it off so E
	# only advances the Don's lines (the game goes to the victory screen after this).
	var player: Node = get_tree().get_first_node_in_group("player")
	var interactions: Node = player.get_node_or_null("InteractingComponent") if player else null
	if interactions != null:
		interactions.canInteract = false
		interactions.currentInteractions.clear()

	await get_tree().create_timer(0.8).timeout

	# the Don's last lines, in the same screen as his payment dialogue
	# (click / E shows the whole line, the next press goes on, the game is paused meanwhile)
	var lines: Array[String] = [
		"What... all of them? You fight dirtier than a sewer drain, kid.",
		"Fine. Keep your restaurant. Keep your cheese. Just... keep away from me.",
	]
	var donDialogue = DON_DIALOGUE_SCENE.instantiate()
	donDialogue.donPortrait = donPortrait
	get_tree().root.add_child(donDialogue)
	await donDialogue.play_lines(lines)

	GameManager.trigger_victory("Don Parmesan's gang is gone. The restaurant is yours!")
