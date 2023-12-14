tool 
extends Action

export (int, "Follow", "Flee") var mode:int = 0
export (bool) var always_succeed:bool = false
export (bool) var can_fly:bool = false
export (bool) var can_jump:bool = false
export (bool) var can_fall:bool = false
export (bool) var can_glide:bool = false
export (bool) var can_warp:bool = false
export (bool) var can_wait:bool = false
export (float) var max_wait:float = 1.0
export (float) var min_distance:float = 0.0
export (bool) var ignore_ending_y:bool = true
export (float) var speed_multiplier:float = 1.0
export (bool) var strafe:bool = false
export (bool) var hide_avatars_if_cutscene:bool = true
export (float) var auto_warp_time_limit:float = 15.0
export (bool) var buffer = false
export (float) var zbuffer_dist = 3.0

var path_controller = null

func _run():
	var pawn = get_pawn()
	var target = get_target()
	
	if pawn == null or target == null:
		return false
	
	if hide_avatars_if_cutscene and blackboard.get("is_cutscene"):
		WorldSystem.set_hide_net_avatars(true)
	
	if path_controller == null:
		path_controller = load("res://mods/LivingWorld/scripts/CustomPathController.gd").new()
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

func set_direction(pawn, target):
	var dir:Vector2 = Vector2()
	if target == null:
		return 
	if target is String:
		dir = Direction.get(target)
	elif target is Vector2:
		dir = target
	elif target is Vector3:
		var dir3 = target - pawn.global_transform.origin
		dir = Vector2(dir3.x, dir3.z).normalized()
	else :
		var dir3 = target.global_transform.origin - pawn.global_transform.origin
		dir = Vector2(dir3.x, dir3.z).normalized()
	
	if pawn is SpriteContainer:
		pawn.direction = Direction.get_nearest(dir)
	else :
		pawn.direction = dir	
	

func _on_paused():
	assert (is_instance_valid(path_controller))
	path_controller.enabled = false

func _on_unpaused():
	assert (is_instance_valid(path_controller))
	path_controller.enabled = is_running()

func _pathing_failed():
	pass

func get_pawn():
	if values.size() >= 2:
		return values[0]
	return .get_pawn()

func get_target():
	if values.size() >= 2:
		return values[1]
	return values[0]

func _get_configuration_warning():
	return verify_child_values(1, 2)
