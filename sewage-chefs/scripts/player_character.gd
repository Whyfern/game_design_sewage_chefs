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

var state: State = State.IDLE
var moveDirection: Vector2 = Vector2.ZERO

@onready var animationTree: AnimationTree = $AnimationTree
@onready var AnimationPlayback: AnimationNodeStateMachinePlayback = $AnimationTree ["parameters/playback"]
@onready var hurtSound: AudioStreamPlayer = $Sounds/HurtSound
@onready var attackSound: AudioStreamPlayer = $Sounds/AttackSound
@onready var stepSound: AudioStreamPlayer = $Sounds/StepsSound
@onready var hitSound: AudioStreamPlayer = $Sounds/HitSound

var poisonedProg : float = 0
var poisonedProgMax : int = 3
var poisonedprogSpeed : int = 4
var poisonedStatus : bool = false
var poisonedDamage : int = 1
var damageTimer : float = 0.0
var damageInterval = 0.5

@onready var HUD : CanvasLayer = get_node("../HUD")
var hpBar : Node

func _ready() -> void:
	animationTree.set_active(true)
	hpBar = await EventBus.HUDloaded
	hpBar.max_value = maxHitPoints

#user's mouse input management (activate only if the game is active)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()
		
		
func _physics_process(delta: float) -> void:
	
	if poisonedStatus:
		poisonedProg = min(poisonedProg + (poisonedprogSpeed * delta), poisonedProgMax)
		#print(poisonedProg)
	else:
		poisonedProg = max(poisonedProg - (poisonedprogSpeed * delta), 0.0)
		damageTimer = 0
	
	if poisonedProg >= poisonedProgMax and poisonedStatus:
		damageTimer += delta
		if damageTimer >= damageInterval:
			take_damage(poisonedDamage)
			damageTimer = 0.0 
	else:
		damageTimer = 0.0
	
	if hpBar:
		hpBar.value = hitpoints
	
		
	# can not move during dialogue
	#if Dialogue.is_active:
		#velocity = Vector2.ZERO
		#
		#state = State.IDLE
		#update_animation()
		#
		#return
		
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
	hitpoints -= damage_taken
	hurtSound.play() # Play mouse squeak whenever player takes damage.
	print(hitpoints)
	if hitpoints <= 0:
		death()
		

func death() -> void:
	print ("I died")

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
	if GameManager.sewageAreaOverlap:
		print("entered ", area.name.to_lower())
	if "sewage_area2d" in area.name.to_lower():
		poisonedStatus = true


func _on_environbox_area_exited(area: Area2D) -> void:
	if GameManager.sewageAreaOverlap:
		print("left ", area.name)
	if "sewage@Area2D" in area.name.to_lower():
		poisonedStatus = false
		
func refill_health() -> void:
	hitpoints = maxHitPoints
	if hpBar:
		hpBar.value = hitpoints
