extends Node3D

@export var dayLength := 15.0
@export var startTime : float
@export var sunEnergy : Curve
@export var moonEnergy : Curve

var time : float
var timeRate : float

# Called when the node enters the scene tree for the first time.
func _ready():
	time = startTime
	timeRate = 1 / dayLength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += timeRate * delta
	
	#rotation_degrees.x = time * 360 + 90
	#sun.light_energy = sunEnergy.sample(time)
	#moon.light_energy = moonEnergy.sample(time)
	
	if time >= 1.0:
		time = 0
