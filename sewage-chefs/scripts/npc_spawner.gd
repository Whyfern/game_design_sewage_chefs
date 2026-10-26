
extends Node

@export var npc_scene: PackedScene
@export var npc_path: Path2D
@export var speed: float = 100.0

var path_follow: PathFollow2D
var movement_tween: Tween


func _ready() -> void:
	EventBus.don_parmesan_spawn_requested.connect(spawn_npc)
	EventBus.don_parmesan_leave_requested.connect(leave_npc)
	
	
func spawn_npc() -> void:
	if is_instance_valid(path_follow):
		return
		
	if npc_scene == null or npc_path == null or npc_path.curve == null or speed <= 0:
		return
		
	var path_length: float = npc_path.curve.get_baked_length()
	if path_length <= 0:
		return
			
	path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false
	path_follow.y_sort_enabled = true
	
	npc_path.add_child(path_follow)
	
	var npc: NPC = npc_scene.instantiate()
	path_follow.add_child(npc)
	npc.position = Vector2.ZERO
	
	movement_tween = create_tween()
	movement_tween.tween_property(
	path_follow, "progress", path_length, path_length / speed
	)
	
	await movement_tween.finished

	if is_instance_valid(npc) and npc.has_method("enable_dialogue"):
		npc.call("enable_dialogue")
	
	
func leave_npc() -> void:
	if not is_instance_valid(path_follow):
		return
		
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
		
	movement_tween = create_tween()
	movement_tween.tween_property(
	path_follow, "progress", 0.0, path_follow.progress / speed
	)
	
	await movement_tween.finished
	
	if is_instance_valid(path_follow):
		path_follow.queue_free()
		path_follow = null
