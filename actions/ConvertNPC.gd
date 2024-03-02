extends Action

func _run():
	var target = values[0]
	var pawn = get_pawn()
	var personality = pawn.get_behavior().personality

	var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")
	var recruitdata = npcmanager.get_data_from_npc(target)
	var npc = npcmanager.get_npc(recruitdata)
	if !npc.has_node("RecruitBehavior"):
		var new_behavior = load("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()
		npc.add_child(new_behavior)
	var behavior = npc.get_behavior()
	behavior.personality = personality
	npc.transform = target.transform
	npc.supress_abilities = pawn.supress_abilities
	pawn.get_parent().add_child(npc)
	npc.global_transform.origin = target.global_transform.origin
	target.visible = false
	target.queue_free()
	npc.spawn_point = target.global_transform.origin
	if pawn.has_method("get_data"):
		var data = pawn.get_data()
		if !data.party_full() and data.has_party():
			var party = data.get_party_data()
			for member in party:
				member.node.add_party_member(npc.get_data(), npc.get_data().recruit)
				npc.get_data().add_party_member(member.node,member.data,member.leader)
				if member.leader:
					npc.get_data().follow_target = member.node.get_parent()
					npc.get_behavior().set_state("Party")
	return true

