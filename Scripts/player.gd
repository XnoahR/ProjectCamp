extends CharacterBody3D

var movement := Vector3(0,0,0)

@export var speed := 5.0

func _ready():
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	movement.x = Input.get_axis("ui_right","ui_left")
	movement.z = Input.get_axis("ui_down","ui_up")
	
	velocity = movement*speed
	_animation()
	move_and_slide()
	pass

func _animation():
	if Input.is_action_pressed("ui_down"):
		$AnimationPlayer.play("Jog Backward")
	if Input.is_action_pressed("ui_up"):
		$AnimationPlayer.play("Jog Forward")
	
