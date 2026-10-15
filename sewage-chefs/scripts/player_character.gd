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

var state: State = State.IDLE
var moveDirection: Vector2 = Vector2.ZERO

@onready var animationTree: AnimationTree = $AnimationTree
@onready var AnimationPlayback: AnimationNodeStateMachinePlayback = $AnimationTree ["parameters/playback"]

func _ready() -> void:
	animationTree.set_active(true)
	
	
#user's mouse input management (activate only if the game is active)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()
		
		
func _physics_process(_delta: float) -> void:
	if not state == State.ATTACK:
		movement_loop()


func movement_loop() -> void: 
	moveDirection.x = int(Input.is_action_pressed("press_d")) - int(Input.is_action_pressed("press_a"))
	moveDirection.y = int(Input.is_action_pressed("press_s")) - int(Input.is_action_pressed("press_w"))
	var motion: Vector2 = moveDirection.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	# Player's sprite flipping in idle / run state 
	if state == State.IDLE or State.RUN:
		if moveDirection.x < -0.01:
			$Sprite2D.flip_h = true
		elif moveDirection.x > 0.01: 
			$Sprite2D.flip_h = false 
	
	if motion != Vector2.ZERO and state == State.IDLE: #if you push input and the character is still (IDLE), it has to start movineg (RUN)
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN: #if character is moving (RUN) with 0 movement, it means it's still (IDLE)
		state = State.IDLE
		update_animation()
		
		
func update_animation() -> void: 
	match state:
		State.IDLE:
			AnimationPlayback.travel("Idle")
		State.RUN:
			AnimationPlayback.travel("run")
		State.ATTACK:
			AnimationPlayback.travel("attack")
			
		
		
func attack() -> void:
	#verify the player is not attacking and set state
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	#find the attack direction and push to animationtree and blendspace2D
	var mousePos: Vector2 = get_global_mouse_position()
	var attackDir: Vector2 = (mousePos - global_position).normalized()
	$Sprite2D.flip_h = attackDir.x < 0 and abs(attackDir.x) >= abs(attackDir.y)
	animationTree.set ("parameters/Attack/BlendSpace2D/blend_position", attackDir)
	update_animation()
	
	#return the palyer state after attacking
	await get_tree().create_timer(attackSpeed).timeout
	state = State.IDLE
		
