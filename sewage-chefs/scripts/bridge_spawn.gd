
extends Node2D

@export var bridge_source_id: int = 0
@export var bridge_atlas: Vector2i = Vector2i(0, 0)

@onready var bridges: TileMapLayer = $SewerProp
@onready var spots: Node2D = $Bridges


func _ready():
	for group in spots.get_children():
		var markers: Array[Marker2D] = []

		for child in group.get_children():
			if child is Marker2D:
				markers.append(child)

		if markers.is_empty():
			continue

		# Kies een willekeurige marker
		var marker = markers.pick_random()

		# Bereken de tilepositie
		var pos = bridges.local_to_map(
			bridges.to_local(marker.global_position)
		)

		# Bepaal rotatie
		var rotation = 0

		if roundi(marker.rotation_degrees) == 90:
			rotation = (
				TileSetAtlasSource.TRANSFORM_TRANSPOSE |
				TileSetAtlasSource.TRANSFORM_FLIP_H
			)

		# Plaats de brug
		bridges.set_cell(
			pos,
			bridge_source_id,
			bridge_atlas,
			rotation
		)
