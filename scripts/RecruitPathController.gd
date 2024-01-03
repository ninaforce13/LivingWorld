extends PathController
var attempts:int = 0
func _pause_controls():
	if not pawn.controls:
		return
	pawn.controls.direction = Vector2()
	if params.can_jump:
		pawn.controls.jump = false
	force_fly = false
	if params.can_fly:
		pawn.controls.force_fly = false
	if params.can_glide:
		pawn.controls.glide = true
	pawn.controls.climb = false

func get_target()->Vector3:
	if target_node.is_empty():
		return target_pos
	if not has_node(target_node):
		return target_pos
	var node = get_node(target_node)
	if not is_instance_valid(node) or not (node is Spatial):
		return target_pos
	return node.global_transform.origin

func control_movement(delta):
	var cur_pos = pawn.global_transform.origin

	var target = get_target()
	var min_xz_distance = sqrt(0.125 * 0.125 * 2)

	if params.max_distance > 0.0 and cur_pos.distance_to(target) > params.max_distance:
		if params.can_warp:
			_warp_to_target()
			arrive(true)
		else :
			arrive(false)
		return


	var moving_xz = false
	var disp_xz = (target - cur_pos) * PLANE_XZ
	if mode == 1:

		disp_xz *= - 1
	var heading = disp_xz.normalized()
	var t = Transform.translated(Vector3(0, 0.2625, 0)) * pawn.global_transform

	if disp_xz.length() > (pawn.velocity * PLANE_XZ).length() * delta and disp_xz.length() > min_xz_distance:
		pawn.controls.direction = Vector2(heading.x, heading.z)
		moving_xz = true
	else :
		pawn.controls.direction = Vector2()
		if pawn.controls.infinite_deceleration:
			pawn.velocity.x = 0.0
			pawn.velocity.z = 0.0

	if not params.can_fall:
		var next_t = Transform.translated(heading * 2.0 * pawn.scale) * t
		if moving_xz and not pawn.test_move(next_t, Vector3.DOWN * 1.5, pawn.infinite_inertia):
			_pause_controls()
			if not pawn.controls.infinite_deceleration and (pawn.velocity * PLANE_XZ).length() > FALL_PREVENTION_STOP_THRESHOLD:
				pawn.velocity.x = _decelerate(pawn.velocity.x, FALL_PREVENTION_DECELERATION, delta)
				pawn.velocity.z = _decelerate(pawn.velocity.z, FALL_PREVENTION_DECELERATION, delta)
			else :
				pawn.velocity.x = 0.0
				pawn.velocity.z = 0.0
				warp_wait_or_fail()
			return


	var dist_y = target.y - cur_pos.y if mode != 1 else 0.0
	var target_is_up = dist_y >= 0.125
	var target_is_down = dist_y <= - 0.125
	var avoid_down = pawn.floor_ray.is_npc_avoid()
	var forwards = disp_xz.normalized()

	if disp_xz.length() < params.min_distance:
		pawn.direction = pawn.controls.direction
		_pause_controls()
		arrive(true)
		return

	if params.can_glide:
		pawn.controls.glide = true

	if pawn.on_ceiling:
		_ceiling_counter += 1
	else :
		_ceiling_counter = 0

	var collides_forwards = (moving_xz and pawn.test_move(t, forwards * 0.25, pawn.infinite_inertia))
	var col_count:int = 0
	var next_t = Transform.translated(heading * 2.0 * pawn.scale) * t
	for i in range(1,10):
		t = Transform.translated(Vector3(0, 0.2625 + i, 0)) * pawn.global_transform
		var collided = pawn.test_move(t, forwards * 0.25, pawn.infinite_inertia)
		if collided:
			col_count+=1

	var climb_height:bool = col_count > 1 and col_count <= 7 and not pawn.in_water
	var fly_height:bool = col_count > 7 or (col_count < 2 and not pawn.test_move(next_t, Vector3.DOWN * 1.5, pawn.infinite_inertia))
	var jump_height:bool = col_count <= 1 and pawn.test_move(next_t, Vector3.DOWN * 1.5, pawn.infinite_inertia)
	var height_cleared:bool = col_count <= 3
	if collides_forwards and pawn.supress_abilities and not height_cleared:
		_pause_controls()
		arrive(true)
		return
	if (collides_forwards or ( not moving_xz and target_is_up) or avoid_down or (dist_y >= 10.0 and params.can_fly)):
		if collides_forwards and climb_height and not pawn.supress_abilities:
			pawn.controls.climb = true
		elif collides_forwards and fly_height:
			pawn.controls.force_fly = true
			pawn.controls.jump = true
		elif collides_forwards and jump_height:
			pawn.controls.jump = true
		elif collides_forwards:
			pawn.controls.climb = false
			pawn.controls.jump = true
			pawn.controls.force_fly = true
		if pawn.controls.climb and _ceiling_counter < 3:
			if target_is_up:
				pawn.controls.direction = pawn.direction
			if not target_is_down:
				pawn.controls.jump = true
		else :
			if collides_forwards:
				pawn.controls.direction = Vector2()

			if (pawn.controls.jump and pawn.velocity.y < - 5.0) or pawn.get_state() == "Gliding":
				if params.can_fly:
					pawn.controls.force_fly = true
					force_fly = true
					pawn.controls.climb = false
				else :
					warp_wait_or_fail()
					return
			if params.can_jump and not pawn.controls.climb:
				pawn.controls.jump = true
				if _ceiling_counter >= 3:

					warp_wait_or_fail()
					return
			else :
				warp_wait_or_fail()
				return
	else :
		if pawn.controls.force_fly:
			if params.can_fly:

				if target_is_up and pawn.velocity.y < 0.0:
					pawn.controls.jump = true
				else :
					pawn.controls.jump = false
					if pawn.on_floor or pawn.in_water:
						pawn.controls.force_fly = false
						force_fly = false
		else :

			pawn.controls.jump = false

	if not moving_xz:
		if mode == 1:
			arrive(false)
			return
		if params.ignore_ending_y:
			_pause_controls()
			arrive(true)
			return
		if pawn.on_floor and target.y <= cur_pos.y - 0.125:
			warp_wait_or_fail()
			return
		if abs(target.y - cur_pos.y) <= 0.125:
			_pause_controls()
			pawn.global_transform.origin = target
			pawn.move_and_collide(Vector3(), false)
			arrive(true)
		if !(abs(target.y - cur_pos.y) <= 0.125) and !params.ignore_ending_y and attempts < 5:
			attempts+=1
			if attempts >= 5:
				_pause_controls()
				arrive(true)
				return
