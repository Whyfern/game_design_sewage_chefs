extends CharacterBody2D
class_name NPC

@export var npc_name: String = "NPC"
@export_multiline var dialogue: String = "Hi!"
@export var interaction_text: String = "Talk"

@export var npc_texture: Texture2D
@export var npc_portrait: Texture2D

@onready var interaction_area: interactable = $Interactable
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	interaction_area.interactName = interaction_text
	interaction_area.interact = talk

	if npc_texture != null:
		sprite.texture = npc_texture


func talk() -> void:
	var lines: Array[Dictionary] = []

	for sentence in dialogue.split("\n", false):
		lines.append({
			"name": npc_name,
			"text": sentence,
			"portrait": npc_portrait
		})

	await DialogueUI.show_dialogue(lines)
