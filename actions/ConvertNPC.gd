extends Action

func _run():
	var target = values[0]
	var pawn = get_pawn()
	var random = Random.new()
	var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")
	var recruitdata = npcmanager.get_data_from_npc(target)
	var npc = npcmanager.get_npc(recruitdata)
	if !npc.has_node("RecruitBehavior"):
		var new_behavior = load("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()
		npc.add_child(new_behavior)
	var behavior = npc.get_node("RecruitBehavior")
	behavior.personality = random.rand_int(behavior.PERSONALITY.size())
	npc.transform = target.transform
	npc.supress_abilities = false
	pawn.get_parent().add_child(npc)
	npc.global_transform.origin = target.global_transform.origin
	target.visible = false
	npc.spawn_point = target.global_transform.origin

	return true

