extends Node

signal stats_changed

var current_day: int = 1
var money: int = 0
var mafia_debt: int = 50
var debt_increase_daily: int = 25

func add_money(amount: int) -> void:
	money += amount
	stats_changed.emit()

func pay_mafia() -> bool:
	if money >= mafia_debt:
		money -= mafia_debt
		stats_changed.emit()
		return true
	return false

func next_day() -> void:
	current_day += 1
	mafia_debt += debt_increase_daily
	stats_changed.emit()
