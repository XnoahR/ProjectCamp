extends Node

var healthValue := 100.0
var hungerValue := 100.0
var thirstValue := 120.0

var maxHealth := 100.0
var maxHunger := 100.0
var maxThirst := 120.0

func _hunger_and_thirst_system(delta, isSprint):
	_hunger_system(delta)
	_thirst_system(delta, isSprint)

func _hunger_system(delta):
	if(hungerValue > 0):
		hungerValue -= 0.08*delta

func _thirst_system(delta, isSprint:bool) -> void:
	if(thirstValue > 0):
		if isSprint:
			thirstValue -= (0.13*5)*delta
		else:
			thirstValue -= 0.13*delta


func _recover_hunger():
	hungerValue = maxHunger
func _recover_thirst():
	thirstValue = maxThirst
