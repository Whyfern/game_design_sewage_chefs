extends CanvasLayer

@onready var money_label: Label = %MoneyLabel
@onready var debt_label: Label = %DebtLabel

func _ready() -> void:
	if GameManager:
		GameManager.stats_changed.connect(update_ui)
		update_ui()

func update_ui() -> void:
	if money_label:
		money_label.text = "Cash: $%d" % GameManager.money
	if debt_label:
		debt_label.text = "Mafia Debt: $%d" % GameManager.mafia_debt
