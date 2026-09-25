extends CharacterBody2D

@export var speed = 120 * 3
var motion = Vector2()

func _ready() -> void:
	pass

func _physics_process(delta):
	get_input()
	move_and_slide()

func get_input():
	motion = Vector2.ZERO
	if Input.is_action_pressed("press_a"):
		motion.x = -speed
		print(motion)
	if Input.is_action_pressed("press_d"):
		motion.x = speed
		print(motion)
	if Input.is_action_pressed("press_w"):
		motion.y = -speed
		print(motion)
	if Input.is_action_pressed("press_s"):
		motion.y = speed
		print(motion)
	velocity = motion
