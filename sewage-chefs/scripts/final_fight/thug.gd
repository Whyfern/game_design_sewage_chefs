extends "res://scripts/rat_enemies.gd"

# One of Don Parmesan's thugs in the final fight.

signal gone(thug: Node, how: String)

@onready var bribeArea: interactable = $BribeInteractable

var isLeaving: bool = false
var messageLabel: Label


func _ready() -> void:
	super._ready()
	bribeArea.interactName = "Bribe (€%d, press e)" % GameManager.BRIBE_PRICE
	bribeArea.interact = _on_bribe
	make_message_label()


func _on_bribe() -> void:
	if isLeaving:
		return

	if not GameManager.spend_money(GameManager.BRIBE_PRICE):
		show_message("Not enough cheese!")
		return

	show_message("Pleasure doing business...")
	leave("bribed")


# the thug stops fighting, walks away and fades out
func leave(how: String) -> void:
	isLeaving = true
	state = State.DEAD
	velocity = Vector2.ZERO
	bribeArea.isInteractable = false
	bribeArea.set_deferred("monitorable", false)
	$Hurtbox.set_deferred("monitorable", false)
	var hitbox: Area2D = find_child("Hitbox", true, false)
	if hitbox != null:
		hitbox.set_deferred("monitoring", false)
	update_animation_to_run()

	var fade: Tween = create_tween().set_parallel(true)
	fade.tween_property(self, "position", position + Vector2(0, 120), 1.2)
	fade.tween_property(self, "modulate:a", 0.0, 1.2)
	await fade.finished

	gone.emit(self, how)
	queue_free()


# replaces death() from rat_enemies.gd so the arena is told that this thug is gone
func death() -> void:
	if isLeaving:
		return
	isLeaving = true
	state = State.DEAD
	spawn_death_animation()
	gone.emit(self, "killed")
	queue_free()


# keeps a bribed thug from going back to fighting after its attack
func attack() -> void:
	await super.attack()
	if isLeaving:
		state = State.DEAD
		update_animation_to_run()


func update_animation_to_run() -> void:
	animationplayback.travel("run")


# small text above the thug's head
func make_message_label() -> void:
	messageLabel = Label.new()
	messageLabel.position = Vector2(-90, -70)
	messageLabel.size = Vector2(180, 24)
	messageLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	messageLabel.add_theme_font_size_override("font_size", 14)
	messageLabel.add_theme_color_override("font_color", Color(0.96, 0.77, 0.26))
	messageLabel.add_theme_color_override("font_outline_color", Color.BLACK)
	messageLabel.add_theme_constant_override("outline_size", 4)
	messageLabel.visible = false
	add_child(messageLabel)


func show_message(text: String) -> void:
	messageLabel.text = text
	messageLabel.visible = true
	messageLabel.modulate.a = 1.0
	var t: Tween = create_tween()
	t.tween_interval(1.0)
	t.tween_property(messageLabel, "modulate:a", 0.0, 0.5)
