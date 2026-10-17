extends CharacterBody2D

#@export var speed: float = 100.0  # Speed along the path
 
# Get a reference to the PathFollow2D parent node
#@onready var path_follow: PathFollow2D = get_parent() as PathFollow2D

#func _physics_process(delta: float) -> void:
	#if path_follow:
		# Increase the progress along the path over time
		#path_follow.progress += speed * delta

@export_category("Stats")
@export var hitpoints:int = 180


func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()
		

func death() -> void:
	queue_free()
