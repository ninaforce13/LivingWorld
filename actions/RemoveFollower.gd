extends Action

func _run():
	remove_recruit()
	return true

func remove_recruit():
	var npc = get_pawn()
	if !npc or !is_instance_valid(npc):
		return
	var recruit
	var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")

	if npcmanager.is_follower_partner():
		var partner = npcmanager.get_partner_by_id(npcmanager.get_follower_partner_id())
		recruit = partner.instance()
		npcmanager.reset_follower()
		WorldSystem.get_level_map().add_child(recruit)
		recruit.global_transform.origin = npc.global_transform.origin
		recruit.direction = npc.direction
		recruit.spawn_point = recruit.global_transform.origin
		return
	var recruitdata = npc.get_data().recruit
	recruit = npcmanager.get_npc(recruitdata)
	var behavior_template = preload("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()
	if !recruit.has_node("RecruitBehavior"):
		recruit.add_child(behavior_template)
	var regionsettings = WorldSystem.get_level_map().default_region_settings
	if !regionsettings or regionsettings.spawn_profile == null:
		var behavior = recruit.get_behavior()
		behavior.personality = behavior.PERSONALITY.TOWNIE
		recruit.supress_abilities = true
	WorldSystem.get_level_map().add_child(recruit)
	if npcmanager.is_follower_custom():
		recruit.add_to_group("custom_recruits")
	if npcmanager.is_follower_partner():
		recruit.add_to_group("idle_partners")
	recruit.global_transform.origin = npc.global_transform.origin
	recruit.direction = npc.direction
	recruit.spawn_point = recruit.global_transform.origin
	npcmanager.reset_follower()
