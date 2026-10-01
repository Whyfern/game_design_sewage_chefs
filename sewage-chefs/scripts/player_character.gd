extends CharacterBody2D

var direction: Vector2 = Vector2(1,0) #variables for player's movement
var speed: int = 250

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("press_a","press_d","press_w","press_s")
	
	velocity = direction * speed  #access velocity, a var for collision
	#animation() #call animation function before creating it
	move_and_slide()
