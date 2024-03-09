extends ActionValue
export (String) var bb_name = "Rogues"
export (bool) var use_engaged_target = false
func get_value():
	if bb_name != "" and !use_engaged_target:
		var target = get_bb(bb_name)
		if !target:
			return true
		if !is_instance_valid(target):
			return true
		if target.world_monster == null or !is_instance_valid(target.world_monster):
			return true
	if use_engaged_target:
		var target = get_engaged_target()
		if !target:
			return true
		if !is_instance_valid(target):
			return true
	return false

func get_engaged_target():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return null
	if !pawn.is_inside_tree():
		return null
	var recruitdata = pawn.get_data()
	var target = recruitdata.engaged_target
	if !target or !is_instance_valid(target):
		return null
	if !target.is_inside_tree():
		return null

	return target
