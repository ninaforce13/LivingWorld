extends Node

signal engaging

var follow_target = null
var engaged_target = null
var engaged:bool = false setget set_engage
var recruit

func set_engage(value):
	engaged = value
	if engaged:
		emit_signal("engaging")




