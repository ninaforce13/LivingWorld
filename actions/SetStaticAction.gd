extends Action
export (float) var static_amount = 0.0
func _run():
	var target = values[0]
	if is_instance_valid(target):
		target.sprite.set_static_amount(static_amount)
	return true
	
