extends Node

var defaultValueRain := 10
# defaultValueRain : int = 10
var defaultValueSunny := 50
var defaultValueCloud := 40
var numberGen : int 
var weather : String
var weatherTime : Array = ["A","B","C"]
	
@onready var valueRain := 10
@onready var valueSunny := 50
@onready var valueCloud := 40

func _ready():
	pass
	
func _process(delta):
	if(Input.is_action_just_pressed("crouch")):
		_weather_system()

func _weather_system():
	numberGen = 0
	print("Value Rain" + str(valueRain))
	print("Value Sunny" + str(valueSunny))
	
	for i in range(weatherTime.size()):
		numberGen = randi_range(0,100)
		if numberGen >= 0 and numberGen <= valueRain:
			weatherTime[i] = "Rainy"
			valueSunny += 10
			valueRain = defaultValueRain
		elif numberGen >= valueRain+1 and numberGen <= valueSunny:
			weatherTime[i] = "Sunny"
			if valueSunny > 20:
				valueSunny = defaultValueSunny
			else:
				valueSunny -= 10
				valueRain += 10
		else :
			weatherTime[i] = "Cloudy"
			valueSunny += 10
			valueRain += 10
		print(numberGen)
		
	print(weatherTime)
	pass
