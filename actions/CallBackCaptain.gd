extends Action
#var owner_data:Dictionary = {"pawn":pawn,"name":pawn.npc_name}
func _run():
	var pawn = get_pawn()
	var captain
	var captain_data = get_bb("sign_owner")
	if !is_instance_valid(captain_data.pawn):
		captain = get_captain_copy(captain_data.name)
		WorldSystem.get_level_map().add_child(captain)
	else:
		captain = captain_data.pawn

	if captain:
		var behavior = captain.get_node("RecruitBehavior")
		if behavior:
			var objectdata = behavior.get_node("Patrol").get_bb("object_data")
			reset_behavior(behavior)
			unregister_from_object(objectdata,captain)
		enable_interaction(captain)
		hide_signpost(pawn)
		reset_captain_position(captain)

	return true

func get_captain_copy(name):
	if Loc.tr(name) == Loc.tr("CAPTAIN_GLADIOLA_NAME"):
		return preload("res://world/recurring_npcs/CaptainGladiola.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_BUFFY_NAME"):
		return preload("res://world/recurring_npcs/CaptainBuffy.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_CLEEO_NAME"):
		return preload("res://world/recurring_npcs/CaptainCleeO.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_CODEY_NAME"):
		return preload("res://world/recurring_npcs/CaptainCodey.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_CYBIL_NAME"):
		return preload("res://world/recurring_npcs/CaptainCybil.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_DREADFUL_NAME"):
		return preload("res://world/recurring_npcs/CaptainDreadful.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_HEATHER_NAME"):
		return preload("res://world/recurring_npcs/CaptainHeather.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_JUDAS_NAME"):
		return preload("res://world/recurring_npcs/CaptainJudas.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_LODESTEIN_NAME"):
		return preload("res://world/recurring_npcs/CaptainLodestein.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_SKIP_NAME"):
		return preload("res://world/recurring_npcs/CaptainSkip.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_WALLACE_NAME"):
		return preload("res://world/recurring_npcs/CaptainWallace.tscn").instance()
	if Loc.tr(name) == Loc.tr("CAPTAIN_ZEDD_NAME"):
		return preload("res://world/recurring_npcs/CaptainZedd.tscn").instance()

func reset_behavior(behavior):
	behavior.get_node("Patrol").reset()
	behavior.get_node("Patrol")._exit_state()
	behavior.set_state("Idle")

func reset_captain_position(pawn):
	pawn.global_transform.origin = pawn.spawn_point

func hide_signpost(pawn):
	pawn.global_transform.origin = pawn.global_transform.origin - Vector3(0,500,0)

func enable_interaction(pawn):
	var interaction = pawn.get_node("Interaction")
	if interaction:
		interaction.disabled = false

func unregister_from_object(objectdata,captain):
	if is_instance_valid(objectdata) and is_instance_valid(captain):
		objectdata.remove_occupant(captain)
