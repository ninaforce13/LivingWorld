extends Action

func _run():
	var pawn = get_pawn()
	var captain = get_bb("sign_owner")
	if captain:
		var behavior = captain.get_node("RecruitBehavior")
		var objectdata = behavior.get_node("Patrol").get_bb("object_data")
		reset_behavior(behavior)
		unregister_from_object(objectdata,captain)
		enable_interaction(captain)
		hide_signpost(pawn)
		reset_captain_position(captain)




	return true

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

func unregister_from_object(objectdata,pawn):
	if objectdata:
		objectdata.remove_occupant(pawn)
