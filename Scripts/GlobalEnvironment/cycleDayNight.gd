extends Node

var isDay     = true
var cycle     = 24/self.getCycle()
var dayLength = self.getTime()

func _process(delta):
	dayLength -= delta

	if dayLength <= 0:
		isDay     = !isDay
		dayLength = cycle

		updateTime(isDay)

func updateTime(isDay):
	if isDay:
		print("Ini Siang")  
	else:
		print("Ini Malam")

func getTime() -> float:
	return Env.hourInGame
	
func getCycle() -> float:
	return Env.changingTime
