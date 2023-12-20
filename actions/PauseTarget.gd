extends Action
export (bool) var pause = false
func _run():
	var target = values[0]
	if is_instance_valid(target):
		if pause:
			var dir3 = get_pawn().global_transform.origin - target.global_transform.origin
			var dir = Vector2(dir3.x, dir3.z).normalized()
			target.direction = dir
			target.set_paused(true)
			target.emote_player.loop("aggro_loop")
		else:
			target.set_paused(false)
			target.emote_player.stop()
	return true
