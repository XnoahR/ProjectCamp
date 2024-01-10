extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$fps.text = "FPS : " + str(Engine.get_frames_per_second())

	pass


func _on_player_stamina_bar(value):
	$ProgressBar.value = value
	pass # Replace with function body.
