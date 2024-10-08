extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 30.0
export (float) var combative_chance = 0.7
export (float) var social_chance = 0.7
export (float) var loner_chance = 0.7
export (float) var townie_chance = 0.7
var random = Random.new()
func is_valid_detection(_detection)->bool:
	if get_parent().state_machine.state == "Defeated":
		return false
	if _detection == get_parent():
		return false
	if !_detection.has_node("InteractionBehavior"):
		return false
	if !_detection.has_node("StateMachine"):
		return false
	var statemachine = _detection.get_node("StateMachine")
	if statemachine.state != "Defeated":
		return false
	if _detection.has_node("RecruitBehavior"):
		var behavior = _detection.get_node("RecruitBehavior")
		if behavior.state != "Fainted":
			return false
	if !random.rand_bool(get_chance()):
		return false
	if !_detection.has_node("ObjectData"):
		var merchantdata = preload("res://mods/LivingWorld/nodes/MerchantData.tscn").instance()
		_detection.add_child(merchantdata)
	return true

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

func get_cooldown_duration()->float:
	return detection_cooldown
