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
	recruit.global_transform.origin = npc.global_transform.origin
	recruit.direction = npc.direction
	SaveState.other_data.LivingWorldData.CurrentFollower = {"recruit":{}, "active":false}
