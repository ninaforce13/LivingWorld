extends "res://world/core/Detector.gd"

export (bool) var sneak_immunity:bool = true setget set_sneak_immunity
export (float) var cooldown_duration:float = 0.1
export (bool) var require_similar_player_scale:bool = true
export (String) var node_detection = "RecruitData"

func is_valid_detection(detection)->bool:
	var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")
	if require_similar_player_scale:
		var my_scale = global_transform.basis.xform(Vector3(0, 1, 0)).length_squared()
		var player_scale = detection.global_transform.basis.xform(Vector3(0, 1, 0)).length_squared()
		if (my_scale < 0.9) != (player_scale < 0.9):
			return false
	if detection.has_node("RecruitData"):
		var recruit = detection.get_node("RecruitData").recruit
		if npcmanager.has_active_follower():
			return !npcmanager.is_current_follower(recruit)
	return .is_valid_detection(detection)

func set_sneak_immunity(value:bool):
	sneak_immunity = value
	if sneak_immunity:
		collision_mask = Collisions.MASK_PLAYER
	else :
		collision_mask = Collisions.MASK_VISIBLE_PLAYER

func get_cooldown_duration()->float:
	return cooldown_duration
	
