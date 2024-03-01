extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 10.0
export (float) var combative_chance = 0.7
export (float) var social_chance = 0.7
export (float) var loner_chance = 0.7
export (float) var townie_chance = 0.0
export (float) var max_player_dist = 50.0
var random = Random.new()
func is_valid_detection(_detection)->bool:
	if get_parent().state_machine.state == "Defeated":
		return false
	var player = WorldSystem.get_player()
	if get_parent().global_transform.origin.distance_to(player.global_transform.origin) > max_player_dist:
		return false
	if !_detection.has_node("ObjectData"):
		return false
	var object_data = _detection.get_node("ObjectData")
	if !object_data.is_empty():
		return false
	if !random.rand_bool(get_chance()):
		return false
	return true
func get_cooldown_duration()->float:
	return detection_cooldown
func get_chance()->float:
	var behavior = get_parent().get_behavior()
	if behavior.personality == behavior.PERSONALITY.COMBATIVE:
		return combative_chance
	if behavior.personality == behavior.PERSONALITY.SOCIAL:
		return social_chance
	if behavior.personality == behavior.PERSONALITY.LONER:
		return loner_chance
	if behavior.personality == behavior.PERSONALITY.TOWNIE:
		return townie_chance
	return social_chance
