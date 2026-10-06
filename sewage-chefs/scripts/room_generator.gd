extends Node2D

@export var roomValue : int = 8

var grid : Array
var gridWidth = 5
var gridHeight = 5

var possibilities : Array
var Currently : Array

var margin: int = 2
var randomWidth : int
var randomHeight : int

var toAdd : Array
var temp_x
var temp_y 

#0 is empty
#1 is normal room
#2 is boss room (maybe)

func _ready():
	create_Grid()

func create_Grid():
	grid=Array()
	grid.resize(gridHeight);
	for i in range(gridHeight):
		grid[i]=Array()
		grid[i].resize(gridWidth)
		grid[i].fill(0)
	generate_layout()
	test_print_Array()

func create_Arrays():
	possibilities = Array()
	Currently = Array()


func test_print_Array():
	for i in grid.size():
		print(grid[i])
	print(randomHeight)
	print(randomWidth)

func generate_layout():
	randomWidth =  randi_range(margin, gridWidth-margin)
	randomHeight = randi_range(margin, gridHeight-margin)
	#grid[randomHeight][randomWidth] = 1
	generate_method_1()

func generate_method_1():
	create_Arrays()
	add_tile(randomWidth, randomHeight, 1)
	while roomValue >= 0:
		var randomSpace = possibilities.pick_random()
		add_tile(randomSpace[0], randomSpace[1], 2)
	print(possibilities)

func add_tile(chosenX : int, chosenY : int, type : int):
	toAdd = [chosenX, chosenY]
	Currently.append(toAdd)
	grid[chosenY][chosenX] = type
	#print(toAdd)
	#possibilities.remove_at(possibilities.find(toAdd))
	#print(chosenX, ',', chosenY)
	for i in Currently:
		temp_x = i[0]
		temp_y = i[1]
		for j in [[temp_x + 1, temp_y],[temp_x - 1, temp_y], [temp_x, temp_y + 1], [temp_x, temp_y -1]]:
			if !(j in possibilities) and (j[0] in range(0, gridWidth)) and (j[1] in range(0, gridHeight)) :
				possibilities.append(j)
	possibilities.erase(toAdd)
	#print(possibilities)
	roomValue -= 1
