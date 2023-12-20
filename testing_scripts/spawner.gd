extends VisibilityNotifier

const MonsterBountyQuest = preload("res://data/quests/noticeboard/MonsterBountyQuest.tscn")
const HoylakeQuest = preload("res://data/quests/sidequests/HoylakeQuest.gd")

const MIN_DISTANCE_TO_PLAYER:float = 10.0

export (float) var spawn_period:float = 10.0
export (int) var initial_spawns:int = 2
export (int) var day_max_spawns:int = 2
export (int) var night_max_spawns:int = 2
export (int) var max_attempts:int = 3
export (float) var remove_below_y:float = - 10.0
export (bool) var spawn_kinematics_on_floor:bool = true
export (Resource) var spawn_profile:Resource setget set_spawn_profile
export (bool) var ignore_visibility:bool = false

var rand:Random
var current_spawns:Array = []
var timer:Timer

var done_initial_spawns:bool = false

func _ready():
	rand = Random.new()
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_timed_spawn")
	timer.start(spawn_period)
	WorldSystem.time.connect("time_skipped", self, "_on_time_skipped")
	WorldSystem.connect("suppress_spawns_changed", self, "_on_suppress_spawns_changed")

func _enter_tree():
	_cull_freed_spawns()
	call_deferred("_do_initial_spawns")

func _on_time_skipped():
	kill_spawns()
	if is_inside_tree():
		_do_initial_spawns()

func _on_suppress_spawns_changed():
	if WorldSystem.is_suppress_spawns():
		kill_spawns()

func kill_spawns():
	for spawn in current_spawns:
		if is_instance_valid(spawn):
			spawn.queue_free()
	current_spawns.clear()

func _cull_freed_spawns():
	for i in range(current_spawns.size() - 1, - 1, - 1):
		if not is_instance_valid(current_spawns[i]) or current_spawns[i].is_queued_for_deletion():
			current_spawns.remove(i)
		else :
			if current_spawns[i] is Spatial and current_spawns[i].is_inside_tree() and current_spawns[i].global_transform.origin.y < remove_below_y:
				current_spawns[i].queue_free()
				current_spawns.remove(i)

func _do_initial_spawns():
	for _i in range(int(max(initial_spawns - current_spawns.size(), 0))):
		if not is_inside_tree():
			return 
		var co = try_spawn()
		if co is GDScriptFunctionState:
			yield (co, "completed")
		yield (Co.next_frame(), "completed")

func _timed_spawn():
	if WorldSystem.is_ai_enabled() and is_inside_tree():
		if ignore_visibility or not is_on_screen():
			_cull_freed_spawns()
			try_spawn()

func try_spawn():
	if WorldSystem.is_suppress_spawns():
		return null
	var max_spawns = day_max_spawns if WorldSystem.time.is_day() else night_max_spawns
	if current_spawns.size() >= max_spawns:
		return null
	var config = _choose_config()
	if config == null:
		return null
	for _i in range(max_attempts):
		var node = _try_spawn_attempt(config)
		if node is GDScriptFunctionState:
			node = yield (node, "completed")
		if node != null:
			return node
		yield (Co.next_frame(), "completed")
		if not is_inside_tree():
			return null
	return null

func _choose_config():
	assert (spawn_profile != null)
	if spawn_profile == null:
		return null
	
	return spawn_profile.choose_config(rand)

func set_spawn_profile(value:Resource):
	spawn_profile = value
	update_configuration_warning()

func _try_spawn_attempt(config):
	assert (is_inside_tree())
	if not is_inside_tree():
		return null
	
	var pos = Vector3(rand.rand_float(), rand.rand_float(), rand.rand_float()) * aabb.size + aabb.position
	var global_pos = global_transform.xform(pos)
	
	for player in WorldSystem.get_players():
		if global_pos.distance_to(player.global_transform.origin) < MIN_DISTANCE_TO_PLAYER:
			return null
	
	var node
	if UserSettings.graphics_world_streaming == 0:
		node = yield (Co.safe_yield_free(self, config.spawn_async()), "completed")
	else :
		node = config.spawn()
	
	if not is_inside_tree():
		node.queue_free()
		return null
	node.add_to_group("free_on_chunk_unload")
	
	if node is Spatial:
		node.transform.origin = pos
		node.transform = transform * node.transform
	
	
	yield (Co.next_frame(), "completed")
	if not is_inside_tree():
		node.queue_free()
		return null
	
	get_parent().add_child(node)
	if UserSettings.graphics_world_streaming == 0 and node.has_method("beam_in"):
		node.beam_in()
	
	if node is KinematicBody:
		if spawn_kinematics_on_floor:
			var orig_xform = node.transform
			var collision = node.move_and_collide(Vector3(0, - 100, 0), false)
			if not collision:
				node.transform = orig_xform
		else :
			
			node.move_and_collide(Vector3(), false)
	var object_data = preload("res://mods/LivingWorld/nodes/WildEncounterObjectData.tscn").instance()
	node.add_child(object_data)	
	current_spawns.push_back(node)
	return node
func setup_recruit_spawner(node):
		get_parent().add_child(node)
		node.global_transform = global_transform
		node.aabb = aabb
		node.aabb.size.y += 10
