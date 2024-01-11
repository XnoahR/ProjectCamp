extends mobMaster
class_name wildAnimal


enum {WATCH,
EAT,
DRINK}

var isIdling
var isReacting = false
var isRoaming = false
var isAware = false
var isRunning = false
var isCooldown = false

@onready var escapeArea = $Escape/CollisionShape3D
@onready var idleState = WATCH

func _ready():
	state = REACT

func _physics_process(delta):
	_current_behaviour()
	print(isCooldown)
	#_react()
	
	pass

func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		_roam()
		_idle()

func _current_behaviour() -> void:
	match state:
		IDLE:
			_idle()
		ROAM:
			_roam()
		_:
			state = IDLE


func _roam():
	print("Wild Roaming")
	await get_tree().create_timer(2.0).timeout
	state = IDLE

func _idle():
	if isCooldown == false:
		isCooldown = true
		idleState = _state_randomize([WATCH,EAT,DRINK])
		match idleState:
			WATCH:
				print("I am watching")
			EAT:
				print("Eat the grass")
			DRINK:
				print("Slurrpp")
		await get_tree().create_timer(3.0).timeout
		isCooldown = false
		state = ROAM

func _react():
	print("RUNNN!")


func _on_area_3d_body_entered(body):
	print("detected")
	isReacting = true
	state = REACT
	pass # Replace with function body.


#func _on_area_3d_body_exited(body):
	#await get_tree().create_timer(3.0).timeout
	#isReacting = false
	
	pass # Replace with function body.
	
func _on_escape_body_exited(body):
	if(isReacting): #masih lari
		escapeArea.disabled = true
		await get_tree().create_timer(3.0).timeout
		if(!isReacting):
			state = IDLE
			print("STOP")
		
	pass # Replace with function body.
	
func _on_escape_body_entered(body):
	isReacting = true
	print("Still Chased")
	pass # Replace with function body.
	
func _state_randomize(states : Array):
	states.shuffle()
	return states.pop_front()
	


