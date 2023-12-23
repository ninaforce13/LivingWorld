extends "res://world/core/Detector.gd"
export (float) var detection_cooldown = 30.0
export (float) var detection_chance = 0.7
func is_valid_detection(_detection)->bool:
	if _detection == get_parent():
		return false
	if !_detection.has_node("RecruitBehavior"):
		return false
	var behavior = _detection.get_node("RecruitBehavior")
	if !behavior.is_interruptible(behavior.state_node):
		return false
	if behavior.state == "Conversation" or behavior.state == "StartConversation":
		return false
	if !_detection.has_node("RecruitData"):
		return false
	var object_data = _detection.get_node("RecruitData")
	if object_data.full_conversation():
		return false
	if detection_chance < randf():
		return false
	return true
func get_cooldown_duration()->float:
	return detection_cooldown
