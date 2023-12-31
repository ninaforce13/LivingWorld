extends WalkAction
export (bool) var use_random = false
export (int,0,50) var random_walk_distance

func _enter_action():
	if use_random:
		var random = Random.new()
		distance = random.rand_int(random_walk_distance)

func _run():
	if hide_avatars_if_cutscene and blackboard.get("is_cutscene"):
		WorldSystem.set_hide_net_avatars(true)

	var who = get_who()
	var start_pos = who.global_transform.origin

	var direction = who.direction
	if direction_override == "opposite":
		direction = - direction
	elif direction_override != "none":
		direction = Direction.get(direction_override)
	who.controls.direction = direction

	who.controls.strafe = strafe

	var end_pos = start_pos + Vector3(direction.x * distance, 0.0, direction.y * distance)

	if path_controller == null:
		path_controller = load("res://mods/LivingWorld/scripts/RecruitPathController.gd").new()
		add_child(path_controller)
		root.connect("paused", self, "_on_paused")
		root.connect("effectively_unpaused", self, "_on_unpaused")
	path_controller.params.can_fly = can_fly
	path_controller.params.can_jump = can_jump
	path_controller.params.can_glide = can_glide
	path_controller.params.can_fall = can_fall
	path_controller.params.can_warp = can_warp
	path_controller.params.can_wait = can_wait
	path_controller.params.max_wait = max_wait
	path_controller.params.ignore_ending_y = true

	who.controls.speed_multiplier = speed_multiplier
	path_controller.set_pawn(who)
	path_controller.target_pos = end_pos
	path_controller.enabled = true
	who.set_paused(false)
	var result = yield (wait_for_result(Co.listen(path_controller, "arrived")), "completed")
	path_controller.enabled = false
	who.controls.speed_multiplier = 1.0
	who.controls.strafe = false

	return result or always_succeed
