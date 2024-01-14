extends Panel

@onready var mainStat = $"Current Main"
@onready var idleStat = $"Current Idle"
@onready var panicMeterStat = $"Current Panic Meter"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_deer__show_info(currentMainState, currentIdleState,panicMeter):
	panicMeterStat.text = "Panic " + str(floori(panicMeter))
	match currentMainState:
		0:
			mainStat.text = "Main State : Roaming"
			idleStat.text = "Idle State : not idling"
		1:
			mainStat.text = "Main State : Idling"
			match currentIdleState:
				0:
					idleStat.text = "Idle State : Watching"
				1:
					idleStat.text = "Idle State : Eating"
				2:
					idleStat.text = "Idle State : Chilling"
		2:
			mainStat.text = "Main State : Running"
			idleStat.text = "Idle State : not idling"
		_:
			mainStat.text = "ywd"
			idleStat.text = "sih"
	
	pass # Replace with function body.
