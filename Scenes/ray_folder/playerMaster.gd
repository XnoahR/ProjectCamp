extends Node

var healthValue := 100.0
var hungerValue := 100.0
var thirstValue := 120.0

var maxHealth := 100.0
var maxHunger := 100.0
var maxThirst := 120.0

func _hunger_and_thirst_system(delta):
	if(hungerValue > 0):
		hungerValue -= 5*delta
	if(thirstValue > 0):
		thirstValue -= 10*delta
		
func _recover_hunger():
	hungerValue = maxHunger
func _recover_thirst():
	thirstValue = maxThirst
