extends Node2D
class_name EnemyHealthBar

# Small health bar that floats above an enemy.

@export var barSize: Vector2 = Vector2(40, 6)
@export var hideWhenFull: bool = false
@export var fullColor: Color = Color(0.3, 0.85, 0.3)
@export var lowColor: Color = Color(0.9, 0.2, 0.15)
@export var backgroundColor: Color = Color(0, 0, 0, 0.6)

var enemy: Node
var maxHitPoints: int = 1
var shownHitPoints: int = -1


func _ready() -> void:
	enemy = get_parent()
	maxHitPoints = max(1, enemy.get("hitpoints"))
	if enemy is Node2D:
		scale = Vector2.ONE / enemy.scale
	z_index = 20
	z_as_relative = false


# only redraws when the hitpoints changed
func _process(_delta: float) -> void:
	var hitpoints: int = enemy.get("hitpoints")
	if hitpoints == shownHitPoints:
		return
	shownHitPoints = hitpoints
	visible = hitpoints > 0 and not (hideWhenFull and hitpoints >= maxHitPoints)
	queue_redraw()


func _draw() -> void:
	var ratio: float = clampf(float(shownHitPoints) / maxHitPoints, 0.0, 1.0)
	var topLeft: Vector2 = -barSize / 2.0
	draw_rect(Rect2(topLeft - Vector2.ONE, barSize + Vector2(2, 2)), backgroundColor)
	draw_rect(Rect2(topLeft, Vector2(barSize.x * ratio, barSize.y)), lowColor.lerp(fullColor, ratio))
