extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 10.0
export (float) var max_player_dist = 50.0
func is_valid_detection(_detection)->bool:
	if get_parent().state_machine.state == "Defeated":
		return false
	if get_parent().global_transform.origin:
		return false
	if !_detection.get_parent().has_node("ObjectData"):
		return false
	var object_data = _detection.get_parent().get_node("ObjectData")
	if !object_data.is_empty():
		return false
	return true
func get_cooldown_duration()->float:
	return detection_cooldown
