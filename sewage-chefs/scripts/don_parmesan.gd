extends NPC

# Don Parmesan: instead of the normal NPC dialogue he opens the debt payment
# screen. When the player pays, the next day starts and he walks away.
# On the final day, paying wins the game. Refusing to pay starts the final fight.

const DEBT_DIALOGUE_SCENE: PackedScene = preload("res://scenes/debt_dialogue.tscn")

var hasBeenPaid: bool = false


func talk() -> void:
	# he is already leaving, nothing more to say
	if hasBeenPaid:
		return

	var debtDialogue = DEBT_DIALOGUE_SCENE.instantiate()
	if npc_portrait != null:
		debtDialogue.donPortrait = npc_portrait
	debtDialogue.donName = npc_name
	get_tree().root.add_child(debtDialogue)

	var result: String = await debtDialogue.run()

	if result == "fight":
		# stop talking to him, the final fight takes over
		hasBeenPaid = true
		interaction_area.isInteractable = false
		interaction_area.set_deferred("monitorable", false)
		BossArena.start_fight(get_tree())
		return

	if result == "paid" and GameManager.is_final_day():
		# last tribute paid: the player is free
		GameManager.tributes_paid += 1
		GameManager.trigger_victory("You paid off Don Parmesan. Free at last!")
		return

	if result == "paid":
		hasBeenPaid = true
		# every tribute paid makes one thug leave the Don's gang
		GameManager.tributes_paid += 1
		interaction_area.isInteractable = false
		interaction_area.set_deferred("monitorable", false)
		
		GameManager.next_day() # debt goes up by debt_increase_daily (25)
		EventBus.debt_paid.emit() # clock and music restart
		EventBus.don_parmesan_leave_requested.emit() # he walks back out
		
		
func _ready() -> void:
	super._ready()
	interaction_area.set_deferred("collision_layer", 0)


func enable_dialogue() -> void:
	if not hasBeenPaid:
		interaction_area.set_deferred("collision_layer", 2)
