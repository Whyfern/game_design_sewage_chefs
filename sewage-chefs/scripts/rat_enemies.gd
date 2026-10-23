extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	RETURN,
	ATTACK, 
	DEAD
}

@export_category("Stats")
@export var enemyspeed: int = 128
@export var enemyatkdmg: int = 10
@export var enemyatkspd: float = 1.0
@export var hitpoints:int = 180
@export var aggrorange: float = 512
@export var atkrange: float = 80
@export_category("Related scenes")
@export var deathPacked: PackedScene

var state: State = State.IDLE

@onready var spawnpoint: Vector2 = global_position
@onready var animationtree: AnimationTree = $AnimationTree
@onready var animationplayback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player") 
@onready var navagent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	animationtree.set_active(true)
	
	await get_tree().physics_frame
	await get_tree().physics_frame


	
func _physics_process(delta: float) -> void:

	if state == State.DEAD or state == State.ATTACK:
		return
		
	if distance_to_player() <= atkrange:
		state = State.ATTACK # CORRETTO: = invece di ==
		attack()
	elif distance_to_player() <= aggrorange:
		state = State.CHASE # CORRETTO: = invece di ==
		move()
	elif global_position.distance_to(spawnpoint) > 32:
		state = State.RETURN
		move()
	elif state != State.IDLE:
		state = State.IDLE
		update_animation()
	

func distance_to_player() -> float:
	# Piccolo controllo di sicurezza nel caso il player non esista ancora o sia morto
	if player != null:
		return global_position.distance_to(player.global_position)
	return 9999.0


func move() -> void:
	if state == State.CHASE and player != null:
		navagent.target_position = player.global_position
	elif state == State.RETURN:
		navagent.target_position = spawnpoint
		
	var nextpathposition: Vector2 = navagent.get_next_path_position()

	
	# CORRETTO: = invece di -
	velocity = global_position.direction_to(nextpathposition) * enemyspeed
	
	if navagent.avoidance_enabled:
		navagent.set_velocity_forced(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
		
	move_and_slide()
	
	# CORRETTO: Aggiunto "state == State.CHASE"
	if state == State.IDLE or state == State.CHASE:
		if velocity.x < -0.01:
			$Sprite2D.flip_h = true
		elif velocity.x > 0.01:
			$Sprite2D.flip_h = false
			
	update_animation()
	

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity # Assicuriamoci che la velocity venga aggiornata se usi l'avoidance


func update_animation() -> void:
	match state:
		State.IDLE:
			animationplayback.travel("idle")
		State.CHASE:
			animationplayback.travel("run")
		State.RETURN:
			animationplayback.travel("run")
		State.ATTACK:
			animationplayback.travel("atk")
		

func attack() -> void:
	if player == null:
		return
		
	var playerposition: Vector2 = player.global_position
	var atkdirection: Vector2 = (playerposition - global_position).normalized()
	$Sprite2D.flip_h = atkdirection.x < 0 and abs(atkdirection.x) >= abs(atkdirection.y)
	
	# Assicurati che il percorso del BlendSpace2D sia corretto
	animationtree.set("parameters/atk/blend_position", atkdirection)
	update_animation()
	
	await get_tree().create_timer(enemyatkspd).timeout
	
	state = State.IDLE
	update_animation() # CORRETTO: Aggiunto per evitare che si blocchi sull'attacco
	

func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()
		

func death() -> void:
	state = State.DEAD # Imposta lo stato a morto per sicurezza
	var deathscene: Node2D = deathPacked.instantiate()
	deathscene.position = global_position 
	%Effects.add_child(deathscene)
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner.has_method("take_damage"): # Controllo per evitare crash se l'area non ha il metodo
		area.owner.take_damage(enemyatkdmg)
