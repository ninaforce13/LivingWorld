extends Action

func _run():
	remove_recruit()
	return true

func remove_recruit():
	var npc = get_pawn()
	var recruitdata = npc.get_node("RecruitData").recruit
	var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")
	var recruit = npcmanager.get_npc(recruitdata)
	var behavior = preload("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()

	if !recruit.has_node("RecruitBehavior"):
		recruit.add_child(behavior)

	WorldSystem.get_level_map().add_child(recruit)
	if npcmanager.is_follower_custom():
		recruit.add_to_group("custom_recruits")
	recruit.global_transform.origin = npc.global_transform.origin
	recruit.direction = npc.direction
	recruit.spawn_point = recruit.global_transform.origin
	npcmanager.reset_follower()
