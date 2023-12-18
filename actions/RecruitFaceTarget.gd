extends Action

export (bool) var snap_to_cardinal:bool = false

func _run():
	var whos = [get_pawn()]
	var target = null
	
	if values.size() == 1:
		target = values[0]
	elif values.size() >= 2:
		whos = []
		for i in range(values.size() - 1):
			if values[i] is Array:
				whos += values[i]
			elif values[i] != null:
				whos.push_back(values[i])
		target = values[values.size() - 1]
	if target == null:
		return true
	
	for who in whos:
		var dir:Vector2 = Vector2()
		if target is String:
			dir = Direction.get(target)
		elif target is Vector2:
			dir = target
		elif target is Vector3:
			var dir3 = target - who.global_transform.origin
			dir = Vector2(dir3.x, dir3.z).normalized()
		else:
			var wr = weakref(target)
			if (!wr.get_ref()) or !target.is_inside_tree():
				dir = Vector2.ZERO.normalized()
			else:
				var dir3 = target.global_transform.origin - who.global_transform.origin
				dir = Vector2(dir3.x, dir3.z).normalized()
		
		if snap_to_cardinal:
			dir = Direction.get(Direction.get_nearest(dir))
		
		if who is SpriteContainer:
			who.direction = Direction.get_nearest(dir)
		else :
			who.direction = dir
	
	return true
