extends Node3D

@export var sunEnergy : Curve
@export var moonEnergy : Curve

@onready var sun := $DirectionalLight3D
@onready var moon := $Moon
@onready var dayNightCycle := get_parent() #dayNightCycle.time

var time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = get_time()
	print("Time: " + str(time))
	rotation_degrees.x = time * 360 + 90
	sun.light_energy = sunEnergy.sample(time)
	moon.light_energy = moonEnergy.sample(time)

func get_time() -> float:
	return dayNightCycle.time
