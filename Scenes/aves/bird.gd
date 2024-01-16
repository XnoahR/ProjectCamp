class_name bird extends mobMaster

enum birdState {ROAM, IDLE, FLY}
enum idleState {WATCH, CHILL, EAT}


var isRoam = false
var isLanding = true
var idleTime = false
var isFly = false

@onready var roamTimer = $RoamTimer
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var currentIdleState = idleState.WATCH

func _ready():
	currentMainState = birdState.ROAM
	roamTimer.one_shot = true
	roamTimer.connect("timeout", _bird_roam_timer)
	pass

func _physics_process(delta):
	_current_behaviour(delta)
	move_and_slide()
	pass

func _current_behaviour(delta):
	match currentMainState:
		birdState.ROAM:
			_roaming()
		birdState.IDLE:
			_idling(delta)
		birdState.FLY:
			_flying()
	pass

func _roaming():
	print("Roaming")
	if !isRoam:
		velocity = Vector3(0,1,3)
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

func _idling(delta):
	if !idleTime:
		print("Idling")
		roamTimer.start(3.0)
		idleTime = true
	
	
func _flying():
	if !isFly:
		print("FLY!")
		roamTimer.start(3.0)
		isFly = true

func _turn_gravity_on(switch:bool):
	if switch:
		velocity.y -= gravity
		velocity.y = max(velocity.y,-10)
	else:
		velocity.y = 0

func _decide_current_state():
	print("Anies ngapain sih")
	match currentMainState:
		birdState.ROAM:
			isLanding = true
		birdState.IDLE:
			print("Rakyat Kontol")
			currentMainState = birdState.FLY
			idleTime = false
		birdState.FLY:
			currentMainState = birdState.ROAM
			isFly = false
	pass

func _bird_roam_timer():
	_decide_current_state()
