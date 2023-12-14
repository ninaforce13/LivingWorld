extends Action
export (bool) var enabled = false
func _run():
	var sprite = get_sprite()
	if sprite:
		if enabled:
			sprite.set_static_amount(.5)
			sprite.set_static_speed( - 0.7)
#			sprite.set_static_offset(-0.5)
		else:
			sprite.set_static_amount(0)
			sprite.set_static_speed(0)
	return true
func get_sprite():
	return values[0]
