class_name mobMaster
extends CharacterBody3D

var health
var speed
var attack

var currentMainState
enum mainState {ROAM, IDLE, RUN}

func _current_behaviour(delta):
	pass

func _roaming():
	print("im roaming")
	pass

func _idling(delta):
	pass

