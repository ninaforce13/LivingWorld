extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 10.0
export (float) var detection_chance = 0.7
export (float) var max_player_dist = 50.0
func is_valid_detection(_detection)->bool:
	var player = WorldSystem.get_player()
	if get_parent().global_transform.origin.distance_to(player.global_transform.origin) > max_player_dist:
		return false
	if !_detection.has_node("ObjectData"):
		return false
	var object_data = _detection.get_node("ObjectData")
	if !object_data.is_empty():
		return false
	if detection_chance > randf():
		return false
	return true
func get_cooldown_duration()->float:
	return detection_cooldown
