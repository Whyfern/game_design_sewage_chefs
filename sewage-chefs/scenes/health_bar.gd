extends ProgressBar

# Call this when the character spawns
func init_health(max_hp: int) -> void:
	max_value = max_hp
	value = max_hp

# Call this when the character takes damage or heals
func update_health(new_amount: int) -> void:
	value = new_amount
