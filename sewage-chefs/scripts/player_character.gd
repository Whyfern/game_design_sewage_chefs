extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK, 
	DEAD
}

@export_category("Stats")
@export var speed: int = 120*3

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO

@onready var animationTree: AnimationTree = $AnimationTree
@onready var AnimationPlayback: AnimationNodeStateMachinePlayback = $AnimationTree ["parameters/playback"]

func _physics_process(_delta: float) -> void:
	movement_loop()


func movement_loop() -> void: 
	move_direction.x = int(Input.is_action_pressed("press_d")) - int(Input.is_action_pressed("press_a"))
	move_direction.y = int(Input.is_action_pressed("press_s")) - int(Input.is_action_pressed("press_w"))
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	# Player's sprite flipping in idle / run state 
	if state == State.IDLE or State.RUN:
		if move_direction.x < -0.01:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0.01: 
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
			
		
		
