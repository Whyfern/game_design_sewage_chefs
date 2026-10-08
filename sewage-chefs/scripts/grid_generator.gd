extends Node2D

@onready var levelManager : Node 

var grid : Array

var roomValue : int
var gridSize : Vector2

var possibilities : Array
var Currently : Array

var margin: int = 1
var randomWidth : int
var randomHeight : int

var toAdd : Array
var temp_x
var temp_y 

#0 is empty
#1 is start room
#2 is normal room
#3 boss room (maybe)

func _ready() -> void:
	#levelManager = get_parent()
	create_Grid()
	create_Arrays()
	generate_layout(1)
	#test_print_Array()
	EventBus.emit_signal("layoutGenerated")

func create_Grid():
	grid=Array()
	grid.resize(gridSize.y);
	for i in range(gridSize.y):
		grid[i]=Array()
		grid[i].resize(gridSize.x)
		grid[i].fill(null)

func create_Arrays():
	possibilities = Array()
	Currently = Array()

#in case we wanted to try a different algorithm
func generate_layout(method : int):
	if method == 1:
		generate_method_1()

func generate_method_1():
	create_Arrays()
	randomWidth =  randi_range(margin, gridSize.x-margin)
	randomHeight = randi_range(margin, gridSize.x-margin)
	add_tile(randomWidth, randomHeight, 1)
	while roomValue > 0 and possibilities.size() > 0:
		var randomSpace = possibilities.pick_random()
		add_tile(randomSpace[0], randomSpace[1], 2)


func add_tile(chosenX : int, chosenY : int, type : int):
	toAdd = [chosenX, chosenY]
	Currently.append(toAdd)
	grid[chosenY][chosenX] = {"grid_pos": Vector2i(chosenX, chosenY), "type": type}
	for i in Currently:
		temp_x = i[0]
		temp_y = i[1]
		for j in [[temp_x + 1, temp_y],[temp_x - 1, temp_y], [temp_x, temp_y + 1], [temp_x, temp_y -1]]:
			if !(j in Currently) and !(j in possibilities) and (j[0] in range(0, gridSize.x)) and (j[1] in range(0, gridSize.y)) :
				possibilities.append(j)
	possibilities.erase(toAdd)
	roomValue -= 1

func test_print_Array():
	for i in grid.size():
		print(grid[i])
	print("width ", randomWidth, ", height ", randomHeight)
	print(randomWidth)

func send_grid():
	return grid
