extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 10.0
export (float) var detection_chance = 0.7

func is_valid_detection(_detection)->bool:
	if !_detection.has_node("ObjectData"):
		return false
	var object_data = _detection.get_node("ObjectData")
	if !object_data.is_empty():
		return false
	if randf() > detection_chance:
		return false
	return true
func get_cooldown_duration()->float:
	return detection_cooldown
