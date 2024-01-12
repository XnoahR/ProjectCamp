extends Node

var defaultValueRain := 10
# defaultValueRain : int = 10
var defaultValueSunny := 50
var defaultValueCloud := 40
var numberGen : int 
var weather : String
var weatherTime : Array = ["A","B","C"]
var interval := 5.0 #Time between morning, day, night
var cloudyVolume := 0.4
var cloudSize : float
#var currentCloudSize : float
var targetCloudSize : float
#var isFogging := false : set = _set_fog

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
	_weather_system()
	
func _process(delta):
	if(Input.is_action_just_pressed("crouch")):
		change_weather("Cloudy")
	rainParticle.emitting = (weather == "Rainy")
	
	match weather:
		"Rainy":
			_rainy()
		"Sunny":
			_sunny()
		"Cloudy":
			_cloudy(delta)
	pass
	
func _weather_system():
	numberGen = 0
	#print("Value Rain" + str(valueRain))
	#print("Value Sunny" + str(valueSunny))
	
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
		#print(numberGen)
		
	print(weatherTime)
	emit_signal("weather_picked")
	pass

func _weather_cycle():
	for i in range(weatherTime.size()):
		change_weather(weatherTime[i])
		#_decide_weather(weather)
		print(weather)
		await timer.timeout
	
	print("weather cycled.")
	emit_signal("weather_cycled")

#func _decide_weather(weatherName : String):
	#rainParticle.emitting = (weatherName == "Rainy")
	##timer.start(interval)
	#match weatherName:
		#"Rainy":
			#_rainy()
		#"Sunny":
			#_sunny()
		#"Cloudy":
			#_cloudy()

func _rainy():
	pass

func _cloudy(delta):
	if cloudSize < targetCloudSize: # 20 -> interval / 4 (transition time) / 5 (delay) (4*5)
		cloudSize += (cloudyVolume/(interval/4.0)) * delta
		set_cloud_scale(cloudSize)
		cloudSize = min(cloudSize, targetCloudSize)
		#print("added cloud volume to :"+str(cloudSize))
		print(cloudSize)
	
func _sunny():
	set_cloud_scale(0.1)
	
func _adjust_cloud(delta):
	if cloudSize < targetCloudSize: # 20 -> interval / 4 (transition time) / 5 (delay) (4*5)
		cloudSize += (cloudyVolume/(interval/4.0)) * delta
		set_cloud_scale(cloudSize)
		cloudSize = min(cloudSize, targetCloudSize)
		#print("added cloud volume to :"+str(cloudSize))
		print(cloudSize)

func set_cloud_scale(scale : float):
	skyMaterial.set("shader_parameter/cloud_coverage", scale)

func get_cloud_scale() -> float:
	return skyMaterial.get("shader_parameter/cloud_coverage")
	
func change_weather(weatherName : String):
	weather = weatherName
	cloudSize = get_cloud_scale()
	targetCloudSize = cloudSize + cloudyVolume
	print("target cloud size:"+str(targetCloudSize))
	timer.start(interval)
	print("Changed weather to: "+weather)

func _on_timer_timeout():
	print("Timer done.")
