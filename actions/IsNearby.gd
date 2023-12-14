extends Action
export (float) var distance = 10.0
export (bool) var inverted = false
func _run():
	var target = get_target()
	if target:
		var global_pos = get_pawn().global_transform.origin	
		if inverted:
			return !global_pos.distance_to(target.global_transform.origin) < distance
		else:
			return global_pos.distance_to(target.global_transform.origin) < distance  
			
	return false

func get_target():
	if values.size() > 0:
		return values[0]
	return null
