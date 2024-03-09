extends CheckConditionAction

export (bool) var is_standard = false

func conditions_met()->bool:
	if root == null:
		setup()
	var target = get_engaged_target()
	if target and is_instance_valid(target):
		return target.has_node("RecruitData") if !is_standard else !target.has_node("RecruitData")
	return check_conditions(self)

func get_engaged_target():
	var pawn = get_pawn()
	var recruitdata = pawn.get_data()
	var target = recruitdata.engaged_target
	if is_instance_valid(target):
		return target
	else:
		return null
