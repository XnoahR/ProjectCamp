extends mobMaster
class_name wildAnimal

enum idleState {WATCH,
EAT,CHILL,
DRINK}

var movement
var isIdling
var isChased = false
var isRoaming = true
var isRunning = false
var isCooldown = false
var isRotationCooldown = false

@export var intervalIdleState : float = 5.0

@onready var panicMeter : float = 0
@onready var rotationCooldown = $rotationCooldown
@onready var roamingCooldown = $roamingCooldown
@onready var escapeArea = $Escape/CollisionShape3D
@onready var currentIdleState = idleState.WATCH

signal _show_info(currentMainState, currentIdleState,panicMeter)

func _ready():
	currentMainState = mainState.ROAM
	rotationCooldown.connect("timeout",_on_rotation_timeout)
	roamingCooldown.connect("timeout",_on_roaming_timeout)

func _process(delta):
	emit_signal("_show_info",currentMainState,currentIdleState,panicMeter)

func _physics_process(delta):
	_current_behaviour(delta)
	move_and_slide()

func _current_behaviour(delta) -> void:
	match currentMainState:
		mainState.IDLE:
			_idling(delta)
		mainState.ROAM:
			_roaming()
		mainState.RUN:
			_running(delta)

func _roaming() -> void:
	if !isRunning:
		if !isRotationCooldown:
			isRotationCooldown = true
			var randomRotation = randf_range(0,360)
			rotate_y(randomRotation)
			rotationCooldown.wait_time = 6.0
			rotationCooldown.one_shot = true
			rotationCooldown.start()
		movement = transform.basis.z * 1
		print("Wild Roaming")
		velocity = movement * 2
		if isRoaming:
			isRoaming = false
			roamingCooldown.wait_time = 6.0
			roamingCooldown.one_shot = true
			roamingCooldown.start()

func _idling(delta) -> void:
	escapeArea.disabled = true
	if isCooldown == false:
		isCooldown = true
		_sub_state_randomize()
		await get_tree().create_timer(intervalIdleState).timeout
		isCooldown = false
		_state_randomize()
	if(!isRunning) && currentMainState == mainState.IDLE:
		_current_idle_state(delta)
	if isRunning:
		currentMainState = mainState.RUN

func _current_idle_state(delta) -> void:
	match currentIdleState:
		idleState.WATCH:
			print("I am watching")
			rotate_y(1*delta)
		idleState.EAT:
			print("Eat the grass")
			rotate_y(-1*delta)
		idleState.CHILL:
			print("So calming")

func _running(delta) -> void:
	isRunning = true
	movement = (transform.basis.z * 1)
	velocity = movement * 2
	if isChased:
		panicMeter += 20 * delta
		panicMeter = min(panicMeter,100)
		escapeArea.disabled = false
	else:
		print("Am i Chased?")
		panicMeter -= 15 * delta
		panicMeter = max(0,panicMeter)
		if(panicMeter <= 0):
			print("back to idle")
			_back_to_idle()
	print(panicMeter)
	
func _back_to_idle() -> void:
	velocity = Vector3.ZERO
	isRunning = false
	currentMainState = mainState.IDLE
	print("STOP")
	
func _sub_state_randomize() -> void:
	var probability : int = 0
	probability = randi_range(0,11)
	if(probability <= 4):
		currentIdleState = idleState.CHILL
	elif(probability <= 7):
		currentIdleState = idleState.WATCH
	else:
		currentIdleState = idleState.EAT

func _state_randomize() -> void:
	var probability : int = 0
	probability = randi_range(0,11)
	if(probability <= 7):
		currentMainState = mainState.IDLE
	else:
		currentMainState = mainState.ROAM

func _on_rotation_timeout() -> void:
	if isRotationCooldown:
		isRotationCooldown = false

func _on_roaming_timeout() -> void:
	if(!isRunning):
		print("Roamer")
		velocity = Vector3.ZERO
		currentMainState = mainState.IDLE
		isRoaming = true

func _on_area_3d_body_entered(body):
	print("detected")
	currentMainState = mainState.RUN
	isChased = true
	pass 

func _on_escape_body_exited(body):
	isChased = false

func _on_escape_body_entered(body):
	isChased = true
	print("Still Chased")

func _on_danger_zone_body_entered(body):
	print("detected")
	currentMainState = mainState.RUN
	isChased = true



