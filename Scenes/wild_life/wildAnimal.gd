extends mobMaster
class_name wildAnimal


enum idleState {WATCH,
EAT,CHILL,
DRINK}

var isIdling
var isChased = false
var isRoaming = false
#var isAware = false
var isRunning = false
var isCooldown = false

@export var intervalIdleState : float = 5.0

@onready var escapeArea = $Escape/CollisionShape3D
@onready var currentIdleState = idleState.WATCH

func _ready():
	currentMainState = mainState.IDLE

func _physics_process(delta):
	_current_behaviour(delta)
	print(currentMainState)
	#_react()
	
	move_and_slide()
	pass

func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		_roam()


func _current_behaviour(delta) -> void:
	match currentMainState:
		mainState.IDLE:
			_idling(delta)
		mainState.ROAM:
			_roaming()
		mainState.RUN:
			_running()


func _roaming():
	if !isRunning:
		print("Wild Roaming")
		velocity.z += 0.01
		await get_tree().create_timer(6.0).timeout
		velocity.z = 0
		currentMainState = mainState.IDLE
	

func _idling(delta) -> void:
	escapeArea.disabled = true
	if isCooldown == false:
		isCooldown = true
		_sub_state_randomize()
		await get_tree().create_timer(intervalIdleState).timeout
		isCooldown = false
		_state_randomize()
	if(!isRunning) && currentMainState == mainState.IDLE:
		match currentIdleState:
				idleState.WATCH:
					print("I am watching")
					rotate_y(1*delta)
				idleState.EAT:
					print("Eat the grass")
					rotate_y(-1*delta)
				idleState.CHILL:
					print("So calming")
				#rotate_z(1*delta)
	if isRunning:
		currentMainState = mainState.RUN
		
func _running():
	isRunning = true
	#isChased = true
	if isChased:
		print("RUNNN!")
		escapeArea.disabled = false
	else:
		print("Am i Chased?")


func _on_area_3d_body_entered(body):
	print("detected")
	currentMainState = mainState.RUN
	isChased = true
	pass 


#func _on_area_3d_body_exited(body):
	#await get_tree().create_timer(3.0).timeout
	#isChased = false
	#pass # Replace with function body.
	
func _on_escape_body_exited(body):
	if(isChased): #masih lari
		isChased = false
		#call_deferred("_disable_escape_area")
		await get_tree().create_timer(3.0).timeout
		#call_deferred("_enable_escape_area")
		call_deferred("_resume_escape_area")

func _resume_escape_area():
	if(!isChased):
		currentMainState = mainState.IDLE
		isRunning = false
		print("STOP")

func _disable_escape_area():
	escapeArea.disabled = true
	
func _enable_escape_area():
	escapeArea.disabled = false

func _on_escape_body_entered(body):
	isChased = true
	print("Still Chased")
	pass # Replace with function body.
	
func _sub_state_randomize():
	var probability : int = 0
	probability = randi_range(0,11)
	if(probability <= 4):
		currentIdleState = idleState.CHILL
	elif(probability <= 7):
		currentIdleState = idleState.WATCH
	else:
		currentIdleState = idleState.EAT
	
func _state_randomize():
	var probability : int = 0
	probability = randi_range(0,11)
	if(probability <= 7):
		currentMainState = mainState.IDLE
	else:
		currentMainState = mainState.ROAM


func _on_danger_zone_body_entered(body):
	print("detected")
	currentMainState = mainState.RUN
	isChased = true
	pass # Replace with function body.
