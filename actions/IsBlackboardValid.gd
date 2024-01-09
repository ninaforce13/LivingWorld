extends ActionValue
export (String) var bb_name = ""
export (bool) var invert = false
export (bool) var check_worldmonster = false
func get_value():
	var target = get_bb(bb_name)
	var world_monster

	if is_instance_valid(target):
		if check_worldmonster:
			if target.world_monster:
				return true if !invert else false
		return true if !invert else false
	if target != null:
		if check_worldmonster:
			if target.world_monster:
				return true if !invert else false
		return true if !invert else false
	return true if !invert else false
