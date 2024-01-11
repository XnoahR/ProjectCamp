class_name mobMaster
extends Node

var health
var speed
var attack

var state
enum {ROAM, IDLE, REACT, RUN}


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
