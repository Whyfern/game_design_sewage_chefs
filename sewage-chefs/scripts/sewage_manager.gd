extends Node2D

@onready var sewageArea = load("res://scenes/sewage.tscn")
@onready var sewageTimer : Timer = $sewage_timer
var sewageAreaInstance : Node

var maxTime : float = 60  # 1000 is for msec
var startingTime : float
var currentTime : float = 0
var totalTime : float = 0
var intervalRate : float = 0.85

var totalIntervals : int
var interval : float
var intervals : Array = []

var roomSize : Vector2
var possibilities : Array = []
var roomValue : int = 10

func _ready() -> void:
	sewageTimer.set_wait_time(maxTime)
	sewageTimer.start()
	
	totalIntervals = roomValue - 1
	calculate_random_decreasing_intervals()


#itteration 3
func calculate_random_decreasing_intervals():
	var raw_weights : Array[float] = []
	var total_weight : float = 0.0
	
	for i in range(totalIntervals):
		# 1. Genereer een puur willekeurige basis (bijv. tussen 0.5 en 1.5)
		var base_random : float = randf_range(0.5, 1.5)
		# 2. Bereken de afname-factor (i neemt toe, dus pow() neemt exponentieel af)
		# Gebruik een waarde zoals 0.75 of 0.8 voor een mooie curve
		var trend_factor : float = pow(0.75, i)
		
		# 3. Combineer willekeur met de dalende trend
		var weight : float = base_random * trend_factor
		
		raw_weights.append(weight)
		total_weight += weight
		
	# Stap 2: Schaal de gewichten zodat ze samen exact maxTime vormen
	var step_count : int = 1
	for weight in raw_weights:
		print("weight=", weight, "   total_weight=", total_weight)
		interval = ((weight / total_weight) * (maxTime))
		intervals.append(maxTime - totalTime)
		totalTime += interval
		print("Interval ", step_count, " | Duur: ", interval, " | Totale tijd: ", totalTime)
		step_count += 1
	intervals.erase(maxTime)


func spawn_sewage():
	print(possibilities)
	var chosenRoom = possibilities.pick_random()
	possibilities.erase(chosenRoom)
	sewageAreaInstance = sewageArea.instantiate()
	sewageAreaInstance.position = Vector2(chosenRoom[0], chosenRoom[1])*roomSize
	self.add_child.call_deferred(sewageAreaInstance)
	#print(intervals)
	pass

func _process(delta: float) -> void:
	if !intervals.is_empty() and (sewageTimer.time_left <= intervals.front()):
		spawn_sewage()
		intervals.pop_front()
	print(currentTime, " ", intervals)
	print(sewageTimer.time_left)

func calculate_Next_Interval():
	while totalIntervals >= 1:
		interval = (maxTime - currentTime) * ((1 - intervalRate)/(1 - pow(intervalRate, totalIntervals)))
		currentTime = currentTime + interval
		print(interval)
		#print(totalIntervals)
		totalIntervals = totalIntervals - 1
		#if totalIntervals < 4:
			#intervalRate = intervalRate - 0.2
	pass

#itteration 2
func calculate_Random_Intervals():
	var raw_weights : Array[float] = []
	var total_weight : float = 0.0
	
	# Stap 1: Genereer willekeurige 'gewichten' voor elk interval
	for i in range(totalIntervals):
		# Kies een random getal (bijv. tussen 1.0 en 10.0)
		# Je kunt deze getallen aanpassen om de variatie groter of kleiner te maken
		var random_weight : float = randf_range(1.0, 5.0)
		raw_weights.append(random_weight)
		total_weight += random_weight
		
	# Stap 2: Schaal de gewichten zodat de som exact gelijk is aan maxTime
	var step_count : int = 1
	for weight in raw_weights:
		# Dit is de normalisatie-stap: (deel / totaal) * limiet
		var interval : float = (weight / total_weight) * maxTime
		
		currentTime += interval
		print("Interval ", step_count, " | Duur: ", interval, " | Totale tijd: ", currentTime)
		
		step_count += 1
