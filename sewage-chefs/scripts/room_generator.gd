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

var boundariesFiles : Array
var boundariesDict : Dictionary = {}
var floorsFiles : Array
var floorsDict : Dictionary = {}
var exceptionList : Array = ["sewer_test.tscn","sewer_testtest.tscn"]

func _ready() -> void:
	EventBus.connect("layoutGenerated", get_grid)
	load_room_elements()
	create_grid()
	await EventBus.layoutGenerated
	set_room_doors()
	calculate_room_depths()
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


func get_currently() -> Array:
	return gridGeneratorInstance.get_currently()

func get_grid():
	if gridGeneratorInstance:
		grid = gridGeneratorInstance.send_grid()
		#test_print_Array()

#func test_print_Array():
	#for i in grid.size():
		#print(grid[i])

func set_room_doors():
	# Set door connections for each room based on neighboring rooms
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			if grid[i][j] == null:
				continue
			var room = grid[i][j]
			room.door_top = ((i - 1) >= 0) and grid[i-1][j] != null
			room.door_bot = ((i + 1) < gridSize.y) and grid[i+1][j] != null
			room.door_left = ((j - 1) >= 0) and grid[i][j-1] != null
			room.door_right = ((j + 1) < gridSize.x) and grid[i][j+1] != null
			
			
func calculate_room_depths():
	var queue: Array = []
	var visited: Dictionary = {}

	# Find the starting room.
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			if grid[i][j] != null and grid[i][j].type == 1:
				queue.append({"pos": Vector2i(i, j), "depth": 0})
				visited[Vector2i(i, j)] = true

	# Explore connected rooms, one step at a time.
	while not queue.is_empty():
		var current = queue.pop_front()
		var pos: Vector2i = current["pos"]
		var depth: int = current["depth"]

		var room = grid[pos.x][pos.y]
		room.depth = depth

		var neighbors = [
			Vector2i(pos.x - 1, pos.y),
			Vector2i(pos.x + 1, pos.y),
			Vector2i(pos.x, pos.y - 1),
			Vector2i(pos.x, pos.y + 1)
		]

		for neighbor in neighbors:
			if neighbor.x < 0 or neighbor.x >= grid.size():
				continue
			if neighbor.y < 0 or neighbor.y >= grid[neighbor.x].size():
				continue
			if grid[neighbor.x][neighbor.y] == null:
				continue
			if visited.has(neighbor):
				continue

			visited[neighbor] = true
			queue.append({
				"pos": neighbor,
				"depth": depth + 1
			})

func draw_map():
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			if grid[i][j] == null:
				continue
			var room = grid[i][j]
			var draw_pos = Vector2(room.grid_pos.x * roomSize.x, room.grid_pos.y * roomSize.y)
			var instance = room_scene.instantiate()
			instance.boundariesDict = boundariesDict
			instance.floorsDict = floorsDict
			instance.position = draw_pos
			instance.type = room.type
			instance.grid_pos = room.grid_pos
			instance.depth = room.depth
			instance.door_top = room.door_top
			instance.door_bot = room.door_bot
			instance.door_left = room.door_left
			instance.door_right = room.door_right
			mapRoot.add_child.call_deferred(instance)
	EventBus.emit_signal("roomGenDone")

func load_room_elements():
	var dir = DirAccess.open("res://scenes/sewer rooms")
	boundariesFiles = dir.get_files_at("res://scenes/sewer rooms/sewer room boundary/")
	for boundary in boundariesFiles:
		var loadedBoundary = load("res://scenes/sewer rooms/sewer room boundary/".path_join(boundary))
		boundariesDict[boundary] = loadedBoundary
	floorsFiles = dir.get_files_at("res://scenes/sewer rooms/sewer_room_floors")
	for floor in floorsFiles:
		if floor not in exceptionList:
			var loadedFloor = load("res://scenes/sewer rooms/sewer_room_floors/".path_join(floor))
			
			floorsDict[floor] = loadedFloor
