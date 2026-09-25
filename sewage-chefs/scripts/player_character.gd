extends CharacterBody2D

@export var speed = 120 * 3
var motion = Vector2()

#var viewRect := get_viewport_rect()

func _ready() -> void:
	pass
	

func _physics_process(delta):
	get_input()
	move_and_slide()

func get_input():
	position.x = clamp(position.x, $CollisionShape2D.shape.size.x / 2, get_viewport_rect().size.x - $CollisionShape2D.shape.size.x / 2)
	position.y = clamp(position.y, $CollisionShape2D.shape.size.x / 2, get_viewport_rect().size.y - $CollisionShape2D.shape.size.x / 2)
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
