extends Action
export (float) var distance = 10.0
export (bool) var inverted = false
export (String) var bb_name:String = ""
func _run():
	var target = get_target()
	if target:
		var global_pos = get_pawn().global_transform.origin
		if inverted:
			if !global_pos.distance_to(target.global_transform.origin) < distance:
				if bb_name != "":
					set_bb(bb_name, target)
				return true
			return false
		else:
			if global_pos.distance_to(target.global_transform.origin) < distance:
				if bb_name != "":
					set_bb(bb_name, target)
				return true
			return false

	return false

func get_target():
	if values.size() > 0:
		return values[0]
	return null
