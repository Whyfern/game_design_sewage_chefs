extends Node2D

@onready var gridGenerator = load("res://scenes/grid_generator.tscn")
@onready var room_scene = load("res://scenes/room.tscn")
@onready var mapRoot = get_node("Map_Root")
var gridGeneratorInstance : Node = null

var grid : Array
var instanceGrid : Array

var roomValue : int
var gridSize : Vector2
var roomSize : Vector2


func _ready() -> void:
	EventBus.connect("layoutGenerated", get_grid)
	create_grid()
	await EventBus.layoutGenerated
	set_room_doors()
	draw_map()
	pass

func create_all_rooms():
	for i in grid:
		for j in i:
			pass
	pass

func create_grid_array():
	instanceGrid=Array()
	instanceGrid.resize(grid.size());
	for i in range(instanceGrid.size()):
		instanceGrid[i]=Array()
		instanceGrid[i].resize(instanceGrid.size())
		instanceGrid[i].fill(0)

func create_grid():
	gridGeneratorInstance = gridGenerator.instantiate()
	gridGeneratorInstance.roomValue = roomValue
	gridGeneratorInstance.gridSize = gridSize
	self.add_child.call_deferred(gridGeneratorInstance)

func get_grid():
	if gridGeneratorInstance:
		grid = gridGeneratorInstance.send_grid()
		test_print_Array()

func test_print_Array():
	for i in grid.size():
		print(grid[i])

func set_room_doors():
	# Set door connections for each room based on neighboring rooms
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			if grid[i][j] == null:
				continue
			var room = grid[i][j]
			room["door_top"] = (i - 1 >= 0) and grid[i-1][j] != null
			room["door_bot"] = (i + 1 < gridSize.y - 1) and grid[i+1][j] != null
			room["door_left"] = (j - 1 >= 0) and grid[i][j-1] != null
			room["door_right"] = (j + 1 < gridSize.x - 1) and grid[i][j+1] != null

func draw_map():
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			if grid[i][j] == null:
				continue
			var room = grid[i][j]
			var draw_pos = Vector2(room["grid_pos"].x * roomSize.x, room["grid_pos"].y * roomSize.y)
			var instance = room_scene.instantiate()
			instance.position = draw_pos
			instance.type = room["type"]
			instance.grid_pos = room["grid_pos"]
			instance.door_top = room["door_top"]
			instance.door_bot = room["door_bot"]
			instance.door_left = room["door_left"]
			instance.door_right = room["door_right"]
			mapRoot.add_child.call_deferred(instance)
	EventBus.emit_signal("roomGenDone")
