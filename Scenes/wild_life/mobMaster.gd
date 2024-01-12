class_name mobMaster
extends CharacterBody3D

var health
var speed
var attack

var currentMainState
enum mainState {ROAM, IDLE, REACT, RUN}


func _roam():
	print("im roaming")
	pass

func _idle():
	pass

func _react():
	print("Kyaa")
	pass

func _run():
	pass
