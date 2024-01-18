class_name bird extends mobMaster

enum birdState {ROAM, IDLE, FLY}
enum idleState {WATCH, CHILL, EAT}


var isRoam = false
var isLanding = true
var idleCooldown
var idleTime = false
var isFly = false
var isHigh = false
var gravityMode
var isDespawning = false
var intervalIdleState := 3.0

# @onready var dangerZone = $DangerZone
@onready var despawnerCountdown = Timer.new()
@onready var roamTimer = $RoamTimer
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var currentIdleState = idleState.WATCH

func _ready():
	currentMainState = birdState.ROAM
	despawnerCountdown.one_shot = true
	despawnerCountdown.connect("timeout",_despawn)
	roamTimer.one_shot = true
	roamTimer.connect("timeout", _bird_roam_timer)

func _physics_process(delta):
	_current_behaviour(delta)
	move_and_slide()

func _current_behaviour(delta):
	match currentMainState:
		birdState.ROAM:
			_roaming()
		birdState.IDLE:
			_idling(delta)
		birdState.FLY:
			_flying(delta)

func _roaming():
	print("Roaming")
	if !isRoam:
		_turn_gravity_on(false)
		var randomY = randi_range(0,360)
		rotate_y(randomY)
		var roamDirection = (transform.basis.z * 1)
		velocity = roamDirection * 20
		velocity.y = 1
		print(velocity)
		isRoam = true
		isLanding = false
		roamTimer.start(1.0)
	if isLanding and isRoam:
		if is_on_floor():
			velocity = Vector3.ZERO
			currentMainState = birdState.IDLE
			print("Floor")
			isRoam = false
			isLanding = false
		else:
			print("Turun")
			velocity += Vector3(0,-0.1,0)
	if isFly:
		currentMainState = birdState.FLY

func _idling(delta):
	_turn_gravity_on(true)
	if !idleCooldown:
		idleCooldown = true
		_sub_state_randomize()
		await get_tree().create_timer(intervalIdleState).timeout
		idleCooldown = false
		_state_randomize()
	if !isFly and currentMainState == birdState.IDLE:
		_current_idle_state(delta)
	if isFly:
		currentMainState = birdState.FLY
		
func _flying(delta):
	print("Flying")
	if gravityMode:
		_turn_gravity_on(false)
	# rotate_y(180)
	velocity.z = transform.basis.z.z
	if(velocity.z < 0 ):
		velocity.z -= 8
		velocity.z = max(velocity.z,-10)
	else:
		velocity.z += 8
		velocity.z = min(velocity.z,10)
	velocity = Vector3(0,velocity.y,velocity.z)
	if(velocity.y < 20) and !isHigh:
		velocity.y += 5*delta
		velocity.y = min(velocity.y,20)
	if(velocity.y >= 20):
		isHigh = true
	if isHigh and velocity.y > 0:
		print("isHigh")
		velocity.y -= 10*delta
		velocity.y = max(velocity.y,0)
		if(isDespawning == false):
			isDespawning = true
			self.add_child(despawnerCountdown)
			despawnerCountdown.start(20.0)
	print(despawnerCountdown.time_left)
	print(velocity)

func _turn_gravity_on(switch:bool):
	if switch:
		velocity.y -= gravity
		velocity.y = max(velocity.y,-10)
		gravityMode = true
	else:
		velocity.y = 0
		gravityMode = false

func _decide_current_state():
	match currentMainState:
		birdState.ROAM:
			isLanding = true
		birdState.IDLE:
			currentMainState = birdState.FLY
			idleTime = false

func _current_idle_state(delta):
	match currentIdleState:
		idleState.WATCH:
			print("Watch")
			rotate_y(1*delta)
		idleState.CHILL:
			print("Chill")
		idleState.EAT:
			print("Eat")
			rotate_y(-1*delta)
	pass

func _sub_state_randomize():
	var probability := randi_range(0,10)
	if(probability < 4): # 40%
		currentIdleState = idleState.WATCH
	elif(probability < 7): # 30%
		currentIdleState = idleState.CHILL
	else: # 30%
		currentIdleState = idleState.EAT

func _state_randomize():
	var probability := randi_range(0,10)
	if(probability < 3): # 30%
		currentMainState = birdState.ROAM
	else:  # 70%
		currentMainState = birdState.IDLE	

func _bird_roam_timer():
	_decide_current_state()

func _on_danger_zone_body_entered(body:Node3D):
	isFly = true
	pass # Replace with function body.

func _despawn():
	queue_free()
	pass # Replace with function body.