extends Action
export (float) var distance = 10.0
export (bool) var inverted = false
export (String) var bb_name:String = ""
export (bool) var set_as_engaged_target = false
func _run():
	var target = get_target()
	if target:
		var global_pos = get_pawn().global_transform.origin
		if inverted:
			if !global_pos.distance_to(target.global_transform.origin) < distance:
				if bb_name != "":
					set_bb(bb_name, target)
				if set_as_engaged_target:
					var target_data = target.get_data()
					var pawn_data = get_pawn().get_data()
					pawn_data.engaged_target = target
					target_data.engaged_target = get_pawn()
					pawn_data.set_engage(true)
					target_data.set_engage(true)
				return true
			return false
		else:
			if global_pos.distance_to(target.global_transform.origin) < distance:
				if bb_name != "":
					set_bb(bb_name, target)
				if set_as_engaged_target:
					var target_data = target.get_data()
					var pawn_data = get_pawn().get_data()
					pawn_data.engaged_target = target
					target_data.engaged_target = get_pawn()
					pawn_data.set_engage(true)
					target_data.set_engage(true)
				return true
			return false

	return false

func get_target():
	if values.size() > 0:
		return values[0]
	return null
