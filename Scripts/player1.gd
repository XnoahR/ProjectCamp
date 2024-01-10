extends CharacterBody3D

var movement := Vector3(0,0,0)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var verticalMovement = 0;
var tbob = 0.0
const MAX_STAMINA := 50.0
const BOB_FREQ  = 2.0
const BOB_AMP = 0.08

signal stamina_bar(value)
signal player_life(health, hunger, thirst)

@export var mouseSensitivity := 0.1
@export var speed := 5.0
@export var jumpForce := 5.0
@export var stamina := 50.0

@onready var health : float = PlayerMaster.healthValue
@onready var hunger : float = PlayerMaster.hungerValue
@onready var thirst : float = PlayerMaster.thirstValue
@onready var canMove := true
@onready var isCrouch := false
@onready var isSprint := false
@onready var isExhausted := false
@onready var cam = $head/Camera3D

func _ready():
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouseX = -event.relative.x
		var mouseY = event.relative.y
		rotate_y(mouseX*0.01*mouseSensitivity)
		cam.rotate_x(mouseY*0.01*mouseSensitivity)
		cam.rotation.x = clamp(cam.rotation.x,deg_to_rad(-60),deg_to_rad(60))

func _process(delta):
	emit_signal("stamina_bar",stamina)
	emit_signal("player_life",health,hunger,thirst)
	PlayerMaster._hunger_and_thirst_system(delta, isSprint)
	_check_life_status()

func _physics_process(delta):
	#Movement Input
	if canMove:
		movement.x = Input.get_axis("right","left")
		movement.z = Input.get_axis("backward","forward")
	
	if(Input.is_key_pressed(KEY_X)):
		_start_exhausted_cooldown()
	#Movement
	movement = (movement.x * transform.basis.x) + (movement.y * transform.basis.y) + (movement.z * transform.basis.z)
	movement = movement.normalized()
	velocity = movement*speed
	#Jump
	_jump(delta)
	#Crouch
	_crouch()
	#Sprint
	_sprint(delta)
	
	#Read Velocity
	velocity.y = verticalMovement
	#print(stamina)
	#print(velocity)
	tbob += delta*velocity.length()*float(is_on_floor())
	print(tbob)
	#cam.transform.origin = _headbob(tbob)
	#Animation and Moving
	_animation()
	move_and_slide()
	pass

#Jump Function
func _jump(delta): #Jump function
	if is_on_floor():
		verticalMovement = 0
	if !is_on_floor():
		if(verticalMovement > -10):
			verticalMovement -= gravity*delta
	if is_on_floor() and (Input.is_key_pressed(KEY_SPACE)):
		verticalMovement = jumpForce

func _crouch(): #Masih belum ada raycast
	if  Input.is_action_pressed("crouch"):
		if is_on_floor():
			$CollisionShape3D.scale.y = 0.5
			speed = 2.5
			isCrouch = true
	else:
		$CollisionShape3D.scale.y = 1
		isCrouch = false
		_default_speed()

func _sprint(delta): #Sprint default hanya nambah speed
	if Input.is_action_pressed("sprint") and stamina > 0 and !isCrouch:
		speed = 10
		stamina -= 20*delta
		isSprint = true
		if(stamina <= 0) :
			isExhausted = true
			isSprint = false
			#wait 3 sec, then isExhausted = false
			_start_exhausted_cooldown()
			pass
		
	else:
		isSprint = false
		if(stamina < MAX_STAMINA) and !isExhausted:
			stamina += 10*delta
		if(stamina > MAX_STAMINA):
			stamina = MAX_STAMINA
		_default_speed()

func _animation():
	var animation_name = "Standard Idle"

	if Input.is_action_pressed("ui_up"):
		animation_name = "Jog Forward"
	elif Input.is_action_pressed("ui_down"):
		animation_name = "Jog Backward"
	elif Input.is_action_pressed("ui_left"):
		animation_name = "Jog Strafe Left"
	elif Input.is_action_pressed("ui_right"):
		animation_name = "Jog Strafe Right"

	if $AnimationPlayer.current_animation != animation_name:
		$AnimationPlayer.play(animation_name)

func _default_speed(): #Set default speed
	speed = 5

func _start_exhausted_cooldown() -> void:
	await get_tree().create_timer(3.0).timeout
	isExhausted = false
	#print("Dah")
	pass

func _check_life_status():
	health = PlayerMaster.healthValue
	hunger = PlayerMaster.hungerValue
	thirst = PlayerMaster.thirstValue
	print(thirst)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time*BOB_FREQ) * BOB_AMP
	return pos
