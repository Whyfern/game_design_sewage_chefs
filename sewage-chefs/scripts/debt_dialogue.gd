extends CanvasLayer

# Payment screen shown when the player talks to Don Parmesan.
# The game is paused while it is open (this node keeps running because its
# process_mode is "Always").
#
# Usage (see don_parmesan.gd):
#   var debtDialogue = preload("res://scenes/debt_dialogue.tscn").instantiate()
#   get_tree().root.add_child(debtDialogue)
#   var result: String = await debtDialogue.run()
# result is "paid", "later" (not yet / not enough money) or "fight" (refused to pay).
# On the final day (GameManager.FINAL_DAY) there is no "Not yet" button.

signal finished(result: String)

enum DialogueState { TYPING_OPENING, CHOOSING, TYPING_REPLY, WAITING_TO_CLOSE }

@export var donPortrait: Texture2D = preload("res://sprites/Rats/MafiaRat.PNG")
@export var donName: String = "Don Parmesan"
@export var secondsPerCharacter: float = 0.025

# {debt}, {money} and {next_debt} are replaced with real numbers
const OPENING_LINES: Array[String] = [
	"Tick-tock, kid. The clock ran out, and so did my patience. That's €{debt}.",
	"Nice little dump you got here. Be a shame if it got... grated. €{debt}, now.",
	"You know why I'm here. €{debt}. Cash, not crackers.",
]
const PAID_LINES: Array[String] = [
	"Pleasure doing business. See you next time, and the tribute goes up to €{next_debt}.",
	"Smart rat. Keep the cheddar coming. Next time it's €{next_debt}.",
]
const NOT_ENOUGH_MONEY_LINES: Array[String] = [
	"Are you trying to pay me in crumbs? €{money} ain't €{debt}.",
	"€{money}? I've found more than that under my couch cushions. I want €{debt}.",
]
# final day versions
const FINAL_OPENING_LINES: Array[String] = [
	"Last day, kid. No more waiting, no more excuses. €{debt}, all of it, right now.",
	"This is it. Pay the €{debt} today, or my boys collect it another way.",
]
const FINAL_PAID_LINES: Array[String] = [
	"Well, well... paid in full. The restaurant is yours, kid. Don't make me come back.",
]
# when the player refuses to pay and the final fight starts
const FIGHT_LINES: Array[String] = [
	"Not paying? Then we do this the old-fashioned way. Boys!",
	"You've got guts, kid. Let's see if they stay inside you. Boys!",
]
const REFUSE_LINES: Array[String] = [
	"Then you'd better start cooking, kid. I'll be right here... waiting.",
	"Not yet? Fine. But the cheese is getting old, and so am I.",
]

@onready var portrait: TextureRect = %Portrait
@onready var nameLabel: Label = %NameLabel
@onready var moneyLabel: Label = %MoneyLabel
@onready var textLabel: RichTextLabel = %TextLabel
@onready var choiceBox: HBoxContainer = %ChoiceBox
@onready var payButton: Button = %PayButton
@onready var refuseButton: Button = %RefuseButton
@onready var fightButton: Button = %FightButton
@onready var continueLabel: Label = %ContinueLabel

var state: DialogueState = DialogueState.TYPING_OPENING
var wasPaid: bool = false
# what the player chose: "paid", "later" or "fight"
var result: String = "later"
var isFinalDay: bool = false
# lines still to show in play_lines() mode
var queuedLines: Array[String] = []
var textTween: Tween
var continueTween: Tween
var wasPausedBefore: bool = false


func _ready() -> void:
	portrait.texture = donPortrait
	nameLabel.text = donName
	choiceBox.visible = false
	continueLabel.visible = false
	payButton.pressed.connect(_on_pay_pressed)
	refuseButton.pressed.connect(_on_refuse_pressed)
	fightButton.pressed.connect(_on_fight_pressed)


# Opens the screen, pauses the game and returns "paid", "later" or "fight".
func run() -> String:
	wasPausedBefore = get_tree().paused
	get_tree().paused = true

	# on the final day there is no "Not yet"
	isFinalDay = GameManager.is_final_day()
	refuseButton.visible = not isFinalDay

	update_money_label()
	payButton.text = "Pay €%d" % GameManager.mafia_debt
	var openingLines: Array[String] = FINAL_OPENING_LINES if isFinalDay else OPENING_LINES
	show_line(openingLines.pick_random(), DialogueState.TYPING_OPENING)

	var chosen: String = await finished
	return chosen


# Shows a few lines of the Don without any buttons (used after the final fight).
# Click / E / Enter shows the whole line, the next press goes to the next line.
# Use with await; it closes itself after the last line.
func play_lines(lines: Array[String]) -> void:
	wasPausedBefore = get_tree().paused
	get_tree().paused = true
	moneyLabel.visible = false
	queuedLines = lines.duplicate()
	show_line(queuedLines.pop_front(), DialogueState.TYPING_REPLY)
	await finished


func update_money_label() -> void:
	moneyLabel.text = "You have €%d  ·  You owe €%d" % [GameManager.money, GameManager.mafia_debt]


# replaces {debt}, {money} and {next_debt} in a line with the current values
func fill_in_numbers(line: String) -> String:
	return line.format({
		"debt": GameManager.mafia_debt,
		"money": GameManager.money,
		"next_debt": GameManager.mafia_debt + GameManager.debt_increase_daily,
	})


func show_line(line: String, newState: DialogueState) -> void:
	state = newState
	choiceBox.visible = false
	stop_continue_blink()

	textLabel.text = fill_in_numbers(line)
	textLabel.visible_ratio = 0.0

	if textTween:
		textTween.kill()
	var duration: float = float(textLabel.get_parsed_text().length()) * secondsPerCharacter
	textTween = create_tween()
	textTween.tween_property(textLabel, "visible_ratio", 1.0, duration)
	textTween.finished.connect(_on_line_typed)


func _on_line_typed() -> void:
	textLabel.visible_ratio = 1.0
	if state == DialogueState.TYPING_OPENING:
		state = DialogueState.CHOOSING
		choiceBox.visible = true
		payButton.grab_focus()
	elif state == DialogueState.TYPING_REPLY:
		state = DialogueState.WAITING_TO_CLOSE
		start_continue_blink()


# _input instead of _unhandled_input, so clicks on the panel also advance the text
func _input(event: InputEvent) -> void:
	if state == DialogueState.CHOOSING:
		# keyboard shortcuts for the two choices
		if event is InputEventKey and event.pressed and not event.echo:
			if event.physical_keycode == KEY_1:
				get_viewport().set_input_as_handled()
				_on_pay_pressed()
			elif event.physical_keycode == KEY_2 and refuseButton.visible:
				get_viewport().set_input_as_handled()
				_on_refuse_pressed()
			elif event.physical_keycode == KEY_3:
				get_viewport().set_input_as_handled()
				_on_fight_pressed()
		return

	var advancePressed: bool = event.is_action_pressed("interact") \
		or event.is_action_pressed("ui_accept") \
		or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	if not advancePressed:
		return
	get_viewport().set_input_as_handled()

	if state == DialogueState.TYPING_OPENING or state == DialogueState.TYPING_REPLY:
		# first press finishes the line instantly
		if textTween:
			textTween.kill()
		_on_line_typed()
	elif state == DialogueState.WAITING_TO_CLOSE:
		# in play_lines() mode, go to the next line first
		if not queuedLines.is_empty():
			show_line(queuedLines.pop_front(), DialogueState.TYPING_REPLY)
		else:
			close()


func _on_pay_pressed() -> void:
	if state != DialogueState.CHOOSING:
		return

	if GameManager.pay_mafia():
		wasPaid = true
		result = "paid"
		if isFinalDay:
			moneyLabel.text = "Debt paid off!  You have €%d" % GameManager.money
			show_line(FINAL_PAID_LINES.pick_random(), DialogueState.TYPING_REPLY)
			return
		moneyLabel.text = "Paid!  You have €%d  ·  Next tribute: €%d" % [
			GameManager.money, GameManager.mafia_debt + GameManager.debt_increase_daily]
		show_line(PAID_LINES.pick_random(), DialogueState.TYPING_REPLY)
	else:
		show_line(NOT_ENOUGH_MONEY_LINES.pick_random(), DialogueState.TYPING_REPLY)


func _on_refuse_pressed() -> void:
	if state != DialogueState.CHOOSING:
		return
	show_line(REFUSE_LINES.pick_random(), DialogueState.TYPING_REPLY)


# the player refuses to pay: the final fight starts after this line
func _on_fight_pressed() -> void:
	if state != DialogueState.CHOOSING:
		return
	result = "fight"
	show_line(FIGHT_LINES.pick_random(), DialogueState.TYPING_REPLY)


func start_continue_blink() -> void:
	continueLabel.visible = true
	continueLabel.modulate.a = 1.0
	if continueTween:
		continueTween.kill()
	continueTween = create_tween().set_loops()
	continueTween.tween_property(continueLabel, "modulate:a", 0.2, 0.5)
	continueTween.tween_property(continueLabel, "modulate:a", 1.0, 0.5)


func stop_continue_blink() -> void:
	if continueTween:
		continueTween.kill()
	continueLabel.visible = false


func close() -> void:
	stop_continue_blink()
	get_tree().paused = wasPausedBefore
	finished.emit(result)
	queue_free()
