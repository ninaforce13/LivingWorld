extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 30.0
export (float) var combative_chance = 0.7
export (float) var social_chance = 0.7
export (float) var loner_chance = 0.7
export (float) var townie_chance = 0.7
var random = Random.new()
var npcmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
func is_valid_detection(_detection)->bool:
	if !npcmanager.get_setting("MagnetismEnabled"):
		return false
	if _detection == get_parent():
		return false
	if !_detection.has_node("RecruitBehavior"):
		return false
	var behavior = _detection.get_node("RecruitBehavior")
	if !behavior.is_interruptible(behavior.state_node):
		return false
	if !_detection.has_node("RecruitData"):
		return false
	var object_data = _detection.get_node("RecruitData")
	if object_data.full_conversation():
		return false
	if !random.rand_bool(get_chance()):
		return false
	return true

func get_chance()->float:
	var behavior = get_parent().get_node("RecruitBehavior")
	if behavior.personality == behavior.PERSONALITY.COMBATIVE:
		return combative_chance
	if behavior.personality == behavior.PERSONALITY.SOCIAL:
		return social_chance
	if behavior.personality == behavior.PERSONALITY.LONER:
		return loner_chance
	if behavior.personality == behavior.PERSONALITY.TOWNIE:
		return townie_chance
	return social_chance

func get_cooldown_duration()->float:
	return detection_cooldown
