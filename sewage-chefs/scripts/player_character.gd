extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 120*3
@export var attackSpeed: float = 0.5
@export var attackDamage: int = 60
@export var maxHitPoints : int = 150
@export var hitpoints: int = 150

@export_category("Acid damage")
@export_range(1.0, 120.0, 0.5) var acidSurvivalSeconds: float = 20.0

var state: State = State.IDLE
var moveDirection: Vector2 = Vector2.ZERO

@onready var animationTree: AnimationTree = $AnimationTree
@onready var AnimationPlayback: AnimationNodeStateMachinePlayback = $AnimationTree ["parameters/playback"]
@onready var hurtSound: AudioStreamPlayer = $Sounds/HurtSound
@onready var attackSound: AudioStreamPlayer = $Sounds/AttackSound
@onready var stepSound: AudioStreamPlayer = $Sounds/StepsSound
@onready var hitSound: AudioStreamPlayer = $Sounds/HitSound

var poisonedProg : float = 0
var poisonedProgMax : int = 1
var poisonedprogSpeed : int = 10
var poisonedStatus : bool = false
var poisonedByArea: bool = false
var poisonedDamage : int = 2
var damageTimer : float = 0.0

var hpBar : Node

func _ready() -> void:
	animationTree.set_active(true)
	# Hear positional enemy sounds from Pip, even when the camera is offset.
	$AudioListener2D.make_current()


	# The HUD may become ready after the player, or may be absent in combat tests.
	EventBus.HUDloaded.connect(_on_hud_loaded)
	var existing_bar = get_node_or_null("../../HUD/HealthBar")
	if existing_bar:
		_on_hud_loaded(existing_bar)


func _on_hud_loaded(bar: TextureProgressBar) -> void:
	hpBar = bar
	hpBar.max_value = maxHitPoints
	hpBar.value = hitpoints

#user's mouse input management (activate only if the game is active)
func _unhandled_input(event: InputEvent) -> void:
	if state == State.DEAD:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	poisonedStatus = poisonedByArea or is_on_sewage_tile()

	if poisonedStatus:
		poisonedProg = min(poisonedProg + (poisonedprogSpeed * delta), poisonedProgMax)
		#print(poisonedProg)
	else:
		poisonedProg = max(poisonedProg - (poisonedprogSpeed * delta), 0.0)

	if poisonedProg >= poisonedProgMax and poisonedStatus:
		# Spread a full health bar over the chosen exposure time (150 HP / 20 s = 7.5 HP/s).
		var damageInterval: float = acidSurvivalSeconds * poisonedDamage / maxi(maxHitPoints, 1)
		damageTimer += delta
		while damageTimer >= damageInterval:
			# Keep the remaining time so the damage rate stays consistent across frame rates.
			damageTimer -= damageInterval
			take_damage(poisonedDamage)
			if state == State.DEAD:
				return
	else:
		damageTimer = 0.0

	if hpBar:
		hpBar.value = hitpoints

	if not state == State.ATTACK:
		movement_loop()


func movement_loop() -> void:
	moveDirection.x = int(Input.is_action_pressed("press_d")) - int(Input.is_action_pressed("press_a"))
	moveDirection.y = int(Input.is_action_pressed("press_s")) - int(Input.is_action_pressed("press_w"))
	var motion: Vector2 = moveDirection.normalized() * speed
	set_velocity(motion)
	move_and_slide()

	# Player's up / down Run animation
	if moveDirection != Vector2.ZERO:
		animationTree.set("parameters/Run/blend_position", moveDirection)

	# Player's sprite flipping in idle / run state
	if state == State.IDLE or state == State.RUN:
		if moveDirection.x < -0.01:
			$ChefRat.flip_h = true
		elif moveDirection.x > 0.01:
			$ChefRat.flip_h = false

	if motion != Vector2.ZERO and state != State.RUN: #if you push input and the character is still (IDLE), it has to start movineg (RUN)
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state != State.IDLE: #if character is moving (RUN) with 0 movement, it means it's still (IDLE)
		state = State.IDLE
		update_animation()


func update_animation() -> void:
	match state:
		State.IDLE:
			AnimationPlayback.travel("Idle")
		State.RUN:
			AnimationPlayback.travel("Run")
		State.ATTACK:
			AnimationPlayback.travel("Attack")


func attack() -> void:
	#verify the player is not attacking and set state
	if state == State.ATTACK:
		return
	state = State.ATTACK

	#find the attack direction and push to animationtree and blendspace2D
	var mousePos: Vector2 = get_global_mouse_position()
	var attackDir: Vector2 = (mousePos - global_position).normalized()
	$ChefRat.flip_h = attackDir.x < 0 and abs(attackDir.x) >= abs(attackDir.y)
	animationTree.set ("parameters/Attack/BlendSpace2D/blend_position", attackDir)
	update_animation()

	#wait for attack duration
	await get_tree().create_timer(attackSpeed).timeout
	if state == State.DEAD:
		return

	# Check what the player is doing *right now* to choose the correct next state
	var isMoving = (int(Input.is_action_pressed("press_d")) - int(Input.is_action_pressed("press_a")) != 0) or \
					(int(Input.is_action_pressed("press_s")) - int(Input.is_action_pressed("press_w")) != 0)

	if isMoving:
		state = State.RUN
	else:
		state = State.IDLE
	update_animation()


# Called by an animation key when Pip swings his pan.
func play_attack_whoosh() -> void:
	attackSound.play()


# Called whenever a foot lands during a walking animation.
func play_footstep() -> void:
	if state == State.RUN:
		stepSound.play()


func take_damage(damage_taken: int) -> void:
	if state == State.DEAD:
		return
	hitpoints -= damage_taken
	hurtSound.play() # Play mouse squeak whenever player takes damage.
	print(hitpoints)
	if hitpoints <= 0:
		death()



#func is_on_sewage_tile() -> bool:
	#for sewage_layer in get_tree().get_nodes_in_group("sewage_tiles"):
		#if not sewage_layer is TileMapLayer:
			#continue
#
		#var tile_position = sewage_layer.local_to_map(
			#sewage_layer.to_local(global_position)
		#)
#
		#if sewage_layer.get_cell_source_id(tile_position) != -1:
			#return true
#
	#return false


func is_on_sewage_tile() -> bool:
	var sewage_layers = get_tree().get_nodes_in_group("sewage_tiles")

	for sewage_layer in sewage_layers:
		if not sewage_layer is TileMapLayer:
			continue

		var tile_position = sewage_layer.local_to_map(
			sewage_layer.to_local(global_position)
		)

		var source_id = sewage_layer.get_cell_source_id(tile_position)

		if source_id != -1:
			return true

	return false



# Ricardo fades out, then the game over screen opens
func death() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	hitpoints = 0
	if hpBar:
		hpBar.value = 0
	velocity = Vector2.ZERO
	AnimationPlayback.travel("Idle")
	$Hurtbox.set_deferred("monitorable", false)
	$Hitbox.set_deferred("monitoring", false)

	var reason: String = "Ricardo was defeated in the sewer."
	if poisonedStatus:
		reason = "Ricardo drowned in the sewage."
	elif get_tree().current_scene.has_node("BossArena"):
		reason = "Don Parmesan's gang got you."

	var fade: Tween = create_tween()
	fade.tween_property($ChefRat, "modulate", Color(1, 0.3, 0.3), 0.2)
	fade.tween_property(self, "modulate:a", 0.0, 0.8)
	await fade.finished

	GameManager.trigger_game_over(reason)

#signal used for Hitboxes - hurtboxes
# Called when Pip's attack hitbox touches another area.
func _on_hitbox_area_entered(area: Area2D) -> void:
	if state != State.ATTACK: # Only deal damage during an attack.
		return
	var target = area.owner
	if is_instance_valid(target) and target.has_method("take_damage"): # Check that the target can receive damage.
		hitSound.play()
		target.take_damage(attackDamage)


func _on_environbox_area_entered(area: Area2D) -> void:
	#if GameManager.sewageAreaOverlap:
		#print("entered ", area.name.to_lower())
	if "sewage_area2d" in area.name.to_lower():
		poisonedByArea = true


func _on_environbox_area_exited(area: Area2D) -> void:
	#if GameManager.sewageAreaOverlap:
		#print("left ", area.name)
	if "sewage_area2d" in area.name.to_lower():
		poisonedByArea = false

func refill_health() -> void:
	hitpoints = maxHitPoints
	if hpBar:
		hpBar.value = hitpoints
