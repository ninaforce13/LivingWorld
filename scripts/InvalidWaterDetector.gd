extends "res://world/core/Detector.gd"

func is_valid_detection(_detection)->bool:
	var raycast = get_parent().get_node("CeilingRay")
	if raycast.get_collider() != null:
		if raycast.get_collider() is GridMap:
			print("Detected invalid water")
			return true
	return false

