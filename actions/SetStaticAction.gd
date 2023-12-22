extends Action
export (float) var static_amount = 0.0
func _run():
	var target = values[0]
	var static_targets:Array
	if is_instance_valid(target):
		if has_bb("static_targets"):
			static_targets = get_bb("static_targets")
		static_targets.push_back(target)
		set_bb("static_targets", static_targets)
		target.sprite.set_static_amount(static_amount)
	return true

