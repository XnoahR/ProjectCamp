extends Node

var defaultValueRain := 10
var defaultValueSunny := 50
var defaultValueCloud := 40
var numberGen : int
var weather : String
var weatherTime : Array = ["Sunny","Cloudy","Rainy"]
var interval := 120.0#(16.0 * 60) #120.0 #Time between morning, day, night
var sunnyVolume : float
var cloudyVolume := 0.15
var cloudSize : float
var currentCloudSize : float
var currentFogSize : float
var targetCloudSize : float
var targetCloudDensity : float
var fogDensity : float
var isFogging := false

signal weather_picked
signal weather_cycled

@onready var valueRain := 10
@onready var valueSunny := 50
@onready var valueCloud := 40
@onready var rainParticle := $RainParticles
@onready var worldEnvironment := $WorldEnvironment
@onready var timer := $Timer
@onready var skyMaterial = worldEnvironment.environment.sky.sky_material

func _ready():
	connect("weather_picked", self._weather_cycle)
	connect("weather_cycled", self._weather_system)
	#_weather_system()
	_weather_cycle()

func _process(delta):
	if(Input.is_action_just_pressed("crouch")):
		timer.start(0.1)
	
	rainParticle.emitting = (weather == "Rainy") #Pour rain particle IF the weather is Rainy
	targetCloudDensity = 0.1 if (weather == "Rainy") else 0.07
	set_cloud_density(targetCloudDensity)
	
	worldEnvironment.environment.volumetric_fog_density = fogDensity
	if !isFogging and fogDensity <= 0:
		pass
	elif isFogging and weather != "Rainy":
		if timer.time_left >= interval/1.5:
			fogDensity = _adjust_value(fogDensity, 0.2, interval/3, (0.2-currentFogSize), delta)
		else:
			currentFogSize = get_fog_density()
			isFogging = false
	else:
		fogDensity = _adjust_value(fogDensity, 0, interval/1.75, currentFogSize, delta)
	
	match weather:
		"Rainy":
			_rainy(delta)
		"Sunny":
			_sunny(delta)
		"Cloudy":
			_cloudy(delta)

func _weather_system():
	numberGen = 0
	
	for i in range(weatherTime.size()):
		numberGen = randi_range(0,100)
		if numberGen >= 0 and numberGen <= valueRain:
			weatherTime[i] = "Rainy"
			valueSunny += 10
			valueRain = defaultValueRain
		elif numberGen >= valueRain+1 and numberGen <= valueSunny:
			weatherTime[i] = "Sunny"
			if valueSunny > 20:
				valueSunny = defaultValueSunny
			else:
				valueSunny -= 10
				valueRain += 10
		else :
			weatherTime[i] = "Cloudy"
			valueSunny += 10
			valueRain += 10
		
	print(weatherTime)
	emit_signal("weather_picked")
	pass

func _weather_cycle():
	for i in range(weatherTime.size()):
		change_weather(weatherTime[i])
		print(weather)
		await timer.timeout
	
	print("weather cycled.")
	emit_signal("weather_cycled")

func _rainy(delta):
	_adjust_cloud(0.6, interval/20.0, (0.6-currentCloudSize), delta)
	var fogValueDiff := (0.01-currentFogSize) if 0.01 > currentFogSize else (currentFogSize-0.01)
	fogDensity = _adjust_value(fogDensity, 0.01, (interval/5.0), (fogValueDiff), delta)
	if timer.time_left <= (interval/10):
		isFogging = true

func _cloudy(delta):
	_adjust_cloud(targetCloudSize, interval/3.0, cloudyVolume, delta)
	
func _sunny(delta):
	_adjust_cloud(0.01, interval/3.0, sunnyVolume, delta)

func _adjust_cloud(targetSize: float, finishTime: float, valueDiff : float, delta):
	cloudSize = get_cloud_scale()
	cloudSize = _adjust_value(cloudSize, targetSize, finishTime, valueDiff, delta)
	set_cloud_scale(cloudSize)
	
func _adjust_value(startSize : float, targetSize : float, finishTime : float, valueDiff : float, delta):
	if startSize < targetSize: # 20 -> interval / 4 (transition time) / 5 (delay) (4*5)
		startSize += (valueDiff/finishTime) * delta
		startSize = min(startSize, targetSize)
		return startSize
	elif startSize > targetSize:
		startSize -= (valueDiff/finishTime) * delta
		startSize = max(startSize, targetSize)
		return startSize
	else:
		return startSize

func set_cloud_scale(scale : float):
	skyMaterial.set("shader_parameter/cloud_coverage", scale)

func get_cloud_scale() -> float:
	return skyMaterial.get("shader_parameter/cloud_coverage")

func set_cloud_density(density : float):
	skyMaterial.set("shader_parameter/_density", density)

func get_fog_density() -> float:
	return worldEnvironment.environment.volumetric_fog_density
	
func change_weather(weatherName : String):
	weather = weatherName
	currentFogSize = get_fog_density()
	currentCloudSize = get_cloud_scale()
	targetCloudSize = currentCloudSize + cloudyVolume
	sunnyVolume = currentCloudSize - 0.01
	timer.start(interval)
	print("Changed weather to: "+weather)

func _on_timer_timeout():
	print("Timer done.")
