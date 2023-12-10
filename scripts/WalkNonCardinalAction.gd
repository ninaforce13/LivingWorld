extends Action
export (String, "none", "down", "up", "left", "right", "opposite") var direction_override:String = "none"
export (float) var distance:float = 10.0
export (bool) var always_succeed:bool = true

export (bool) var can_fly:bool = false
export (bool) var can_jump:bool = false
export (bool) var can_glide:bool = false
export (bool) var can_fall:bool = false
export (bool) var can_warp:bool = false
export (bool) var can_wait:bool = false
export (float) var max_wait:float = 1.0
export (float) var speed_multiplier:float = 1.0
export (bool) var strafe:bool = false
export (bool) var hide_avatars_if_cutscene:bool = true

var path_controller = null

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
	
	var end_pos = start_pos + Vector3(direction.x + randi()%10 * distance, 0.0, direction.y +randi()%10 * distance)
	
	if path_controller == null:
		path_controller = PathController.new()
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

func _on_paused():
	assert (is_instance_valid(path_controller))
	path_controller.enabled = false

func _on_unpaused():
	assert (is_instance_valid(path_controller))
	path_controller.enabled = is_running()

func get_who():
	if values.size() > 0:
		return values[0]
	return blackboard.pawn

func _get_configuration_warning():
	return verify_child_values(0, 1)
