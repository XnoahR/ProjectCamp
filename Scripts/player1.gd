extends CharacterBody3D

var movement := Vector3(0,0,0)

@export var speed := 5.0
@export var mouseSensitivity := 0.1
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
	movement.x = Input.get_axis("right","left")
	movement.z = Input.get_axis("backward","forward")
	
	
	movement = (movement.x * transform.basis.x) + (movement.z * transform.basis.z)
	movement = movement.normalized()
	velocity = movement*speed
	_animation()
	move_and_slide()
	pass

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


	
