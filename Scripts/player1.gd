extends CharacterBody3D

var movement := Vector3(0,0,0)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var verticalMovement = 0;
var MAX_STAMINA := 50.0


@export var mouseSensitivity := 0.1
@export var speed := 5.0
@export var jumpForce := 5.0
@export var stamina := 50.0

@onready var canMove := true
@onready var isCrouch := false
@onready var isSprint := false
@onready var cam = $Camera3D

func _ready():
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouseX = -event.relative.x
		var mouseY = event.relative.y
		rotate_y(mouseX*0.01*mouseSensitivity)
		cam.rotate_x(mouseY*0.01*mouseSensitivity)
		cam.rotation.x = clamp(cam.rotation.x,deg_to_rad(-60),deg_to_rad(60))
		
func _physics_process(delta):
	#Movement Input
	if canMove:
		movement.x = Input.get_axis("right","left")
		movement.z = Input.get_axis("backward","forward")
	
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
	print(velocity)
	
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
		
		
	else:
		if(stamina < MAX_STAMINA):
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
