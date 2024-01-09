extends Action
const signpost_scene = preload("res://mods/LivingWorld/nodes/woodenplaque.tscn")
export(bool) var remove = false
func _run():
	var pawn = get_pawn()
	var level = WorldSystem.get_level_map()
	if !remove:
		var signpost = signpost_scene.instance()
		level.add_child(signpost)
		signpost.global_transform.origin = pawn.spawn_point
		signpost.get_node("InteractionBehavior").set_bb("sign_owner",pawn)
	if remove:
		if level.has_node("LunchPost"):
			var signpost = pawn.get_node("LunchPost")
			if signpost:
				level.remove_child(signpost)
			if signpost:
				signpost.queue_free()
	return true
