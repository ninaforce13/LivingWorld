extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 10.0
export (float) var detection_chance = 0.7

func is_valid_detection(_detection)->bool:
	if detection_chance > randf():
		return false
	if _detection is Area and _detection.overlaps_body(get_parent()):
		return true
	if _detection is RigidBody:
		return true
	return false
func get_cooldown_duration()->float:
	return detection_cooldown
