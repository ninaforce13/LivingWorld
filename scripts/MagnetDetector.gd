extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 10.0
export (float) var detection_chance = 0.7
var random = Random.new()
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
func is_valid_detection(_detection)->bool:
	if !manager.get_setting("MagnetismEnabled"):
		return false
	if !random.rand_bool(detection_chance):
		return false
	if !(_detection is Area and _detection.overlaps_body(get_parent())):
		return false
	if !(_detection is RigidBody):
		return false
	return true
func get_cooldown_duration()->float:
	return detection_cooldown
