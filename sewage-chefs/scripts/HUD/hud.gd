extends CanvasLayer

@onready var currency_label: Label = %CurrencyLabel

func _ready() -> void:
	if GameManager:
		GameManager.stats_changed.connect(update_ui)
		update_ui()

func update_ui() -> void:
	var current_money = GameManager.money if GameManager else 0
	var current_debt = GameManager.mafia_debt if GameManager else 50

	if currency_label:
		# Format as "current / target" (e.g., "0 / 50")
		currency_label.text = "%d/%d" % [current_money, current_debt]
		
		# Change color dynamically based on whether the goal is reached
		if current_money >= current_debt:
			# Green when goal is met or exceeded
			currency_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		else:
			# Red when still under debt
			currency_label.add_theme_color_override("font_color", Color(0.663, 0.0, 0.0, 1.0))
