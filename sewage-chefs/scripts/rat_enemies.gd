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
@export var aggrorange: float = 384
# Keep attacks reachable above the rat's tall body collider, too.
@export var atkrange: float = 96
@export_category("Related scenes")
@export var deathPacked: PackedScene
@export_category("Idle audio")
@export_range(0.1, 60.0, 0.1) var idleGroanIntervalSeconds: float = 4.0

var state: State = State.IDLE:
	set(nextState):
		state = nextState
		_update_combat_threat()
var hitTargets: Array[Node] = []
var navigationReady: bool = false

@onready var spawnpoint: Vector2 = global_position
@onready var animationtree: AnimationTree = $AnimationTree
@onready var animationplayback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var navagent: NavigationAgent2D = $NavigationAgent2D
@onready var attackPivot: Node2D = $AttackPivot
@onready var enemyStepSound: AudioStreamPlayer = $SoundManager/enStepsSound
@onready var enemyAtkSound: AudioStreamPlayer = $SoundManager/enAtkSound
@onready var enemyGroanSound: AudioStreamPlayer2D = $SoundManager/enGroanSound
@onready var idleGroanTimer: Timer = $SoundManager/IdleGroanTimer


func _ready() -> void:
	animationtree.set_active(true)
	_update_combat_threat()
	# Give newly generated navigation maps time to synchronize before path queries.
	await get_tree().physics_frame
	await get_tree().physics_frame
	navigationReady = true


func _update_combat_threat() -> void:
	if not is_inside_tree():
		return
	var active = state == State.CHASE or state == State.ATTACK
	# Group membership is a set: repeated CHASE updates cannot count a rat twice.
	if active == is_in_group("combat_threats"):
		return
	if active:
		add_to_group("combat_threats")
	else:
		remove_from_group("combat_threats")
	EventBus.enemyCombatChanged.emit(self, active)


func _exit_tree() -> void:
	if is_in_group("combat_threats"):
		remove_from_group("combat_threats")
		EventBus.enemyCombatChanged.emit(self, false)



func _physics_process(delta: float) -> void:
	if not navigationReady:
		return

	if state == State.DEAD or state == State.ATTACK:
		_update_idle_groan()
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
	_update_idle_groan()


func _update_idle_groan() -> void:
	# Cancel the waiting period and any groan as soon as the rat stops being idle.
	if state != State.IDLE:
		idleGroanTimer.stop()
		enemyGroanSound.stop()
		return

	# The first groan starts after one interval; later ones keep the same cadence.
	if idleGroanTimer.is_stopped():
		idleGroanTimer.start(idleGroanIntervalSeconds)


func play_idle_groan() -> void:
	# The state might have changed since the timer was started.
	if state == State.IDLE:
		# Never overlap voices if a longer recording is added later.
		if not enemyGroanSound.playing:
			enemyGroanSound.play()
		idleGroanTimer.start(idleGroanIntervalSeconds)


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


# called by animation when sprite touches ground
func play_enemy_footstep() -> void:
	if state != State.CHASE: # steps only when charge state
		return
	if get_real_velocity().length() < 5.0:
		return
	enemyStepSound.play()


func attack() -> void:
	if player == null:
		return
	hitTargets.clear()
	var playerposition: Vector2 = player.global_position
	var atkdirection: Vector2 = (playerposition - global_position).normalized()
	$Sprite2D.flip_h = atkdirection.x < 0 and abs(atkdirection.x) >= abs(atkdirection.y)
	# Sprite flipping only changes the picture. Mirror the animated hitbox too.
	attackPivot.scale = Vector2(-1.0 if $Sprite2D.flip_h else 1.0, 1.0)
	animationtree.set("parameters/atk/blend_position", atkdirection)
	# Restart the swing even if the previous attack has not transitioned to idle yet.
	animationplayback.start("atk", true)
	await get_tree().create_timer(enemyatkspd).timeout
	if state == State.DEAD:
		return
	state = State.IDLE
	update_animation() # No blocking during Atk


func play_enemy_atk() -> void:
	enemyAtkSound.play()


func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()


func death() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD # Imposta lo stato a morto per sicurezza
	spawn_death_animation()
	queue_free()


# added to the parent, otherwise it gets freed together with the rat
func spawn_death_animation() -> void:
	var deathscene: Node2D = deathPacked.instantiate()
	var parentNode: Node = get_parent()
	# The effect becomes a sibling, so it can use this rat's complete transform.
	deathscene.transform = transform
	deathscene.z_index = z_index
	deathscene.z_as_relative = z_as_relative
	var ratSprite: Sprite2D = $Sprite2D
	var deathSprite: Sprite2D = deathscene.get_node("death_anim")
	deathSprite.transform = ratSprite.transform
	deathSprite.flip_h = ratSprite.flip_h
	deathSprite.flip_v = ratSprite.flip_v
	deathSprite.centered = ratSprite.centered
	# Retain the death sheet's -17 px correction: its artwork sits lower in each frame.
	deathSprite.offset += ratSprite.offset
	parentNode.add_child.call_deferred(deathscene)


func _on_hitbox_area_entered(area: Area2D) -> void:
	# A moving hitbox can enter the same hurtbox several times during a swing.
	# Damage each target only once, and only while attacking.
	if state != State.ATTACK:
		return
	var target = area.owner
	if is_instance_valid(target) and target.has_method("take_damage") and target not in hitTargets:
		hitTargets.append(target)
		target.take_damage(enemyatkdmg)
