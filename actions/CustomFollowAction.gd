extends FollowAction

export (bool) var buffer = false
export (float) var zbuffer_dist = 3.0

func _run():
	var pawn = get_pawn()
	var target = get_target()

	if pawn == null or target == null:
		return always_succeed

	if hide_avatars_if_cutscene and blackboard.get("is_cutscene"):
		WorldSystem.set_hide_net_avatars(true)

	if path_controller == null:
		path_controller = load("res://mods/LivingWorld/scripts/RecruitPathController.gd").new()
		add_child(path_controller)
		root.connect("paused", self, "_on_paused")
		root.connect("effectively_unpaused", self, "_on_unpaused")
	path_controller.mode = mode
	path_controller.params.can_fly = can_fly
	path_controller.params.can_jump = can_jump
	path_controller.params.can_glide = can_glide
	path_controller.params.can_fall = can_fall
	path_controller.params.can_warp = can_warp
	path_controller.params.can_wait = can_wait
	path_controller.params.max_wait = max_wait
	path_controller.params.ignore_ending_y = ignore_ending_y
	path_controller.params.min_distance = min_distance
	path_controller.params.auto_warp_time_limit = auto_warp_time_limit

	pawn.controls.speed_multiplier = speed_multiplier
	pawn.controls.strafe = strafe

	path_controller.set_pawn(pawn)
	if !target is Vector3 and buffer:
		target = target.global_transform.origin + Vector3(0,0,zbuffer_dist)
	if target is Vector3:
		path_controller.target_pos = target
	else :
		if !is_instance_valid(target):
			path_controller.target_node = pawn.get_path()
		else:
			path_controller.target_node = target.get_path()
	path_controller.enabled = true
	pawn.set_paused(false)
	var result = yield (wait_for_result(Co.listen(path_controller, "arrived")), "completed")
	if result and buffer:
		path_controller.target_pos = target - Vector3(0,0,zbuffer_dist)
		result = yield (wait_for_result(Co.listen(path_controller, "arrived")), "completed")
	path_controller.enabled = false

	pawn.controls.speed_multiplier = 1.0
	pawn.controls.strafe = false

	if not result:
		_pathing_failed()

	return result or always_succeed
