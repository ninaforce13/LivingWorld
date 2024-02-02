extends VisibilityNotifier

const MAX_SPAWN_DISTANCE:float = 60.0
const MIN_DISTANCE_TO_PLAYER:float = 10.0
var npcmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
export (float) var spawn_period:float = 10.0
export (int) var initial_spawns:int = 2
export (int) var day_max_spawns:int = 3
export (int) var night_max_spawns:int = 1
export (int) var max_attempts:int = 3
export (float) var remove_below_y:float = - 10.0
export (bool) var spawn_kinematics_on_floor:bool = true
export (bool) var ignore_visibility:bool = false
export (int) var forced_personality = -1
export (bool) var supress_abilities = false
var delay
var current_spawns:Array = []
var timer:Timer
var random:Random
var done_initial_spawns:bool = false

func _ready():
	random = Random.new()
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_timed_spawn")
	UserSettings.connect("settings_changed", self,"_update_population")
	timer.start(clamp(spawn_period - random.rand_float(),1.0,10.0))

	_update_population()

func _update_population():
	var population = npcmanager.get_setting("NPCPopulation")
	day_max_spawns = population
	night_max_spawns = clamp(day_max_spawns - 1,1,3)


#func _enter_tree():
#	_cull_freed_spawns()
#	call_deferred("_do_initial_spawns")


func try_spawn():
	var max_spawns = day_max_spawns if WorldSystem.time.is_day() else night_max_spawns
	if current_spawns.size() >= max_spawns:
		return null

	for _i in range(max_attempts):
		var node = _try_spawn_attempt()
		if node is GDScriptFunctionState:
			node = yield (node, "completed")
		if node != null:
			return node
		yield (Co.next_frame(), "completed")
		if not is_inside_tree():
			return null
	return null

func _try_spawn_attempt():
	assert (is_inside_tree())
	if not is_inside_tree():
		return null

	var pos = aabb.position + Vector3(randf() * aabb.size.x, randf() * aabb.size.y, randf() * aabb.size.z)
	var global_pos = global_transform.xform(pos)
	for player in WorldSystem.get_players():
		var flat_pos = Vector3(global_pos.x, player.global_transform.origin.y, global_pos.z)
		if flat_pos.distance_to(player.global_transform.origin) < MIN_DISTANCE_TO_PLAYER:
			return null

	var npc = npcmanager.create_npc(forced_personality,supress_abilities)
	add_child(npc)
	npc.global_transform.origin = global_pos + Vector3(0,5,0)
	if npc is KinematicBody:
		var orig_xform = npc.transform
		var collision = npc.move_and_collide(Vector3(0, - 100, 0), false)
		if not collision:
			npc.transform = orig_xform
	if npc:
		current_spawns.push_back(npc)

		return npc
	return null


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
	var player = WorldSystem.get_player()
	if WorldSystem.is_ai_enabled() and is_inside_tree():
		_cull_freed_spawns()
		if (ignore_visibility or not is_on_screen()) and self.global_transform.origin.distance_to(player.global_transform.origin) < MAX_SPAWN_DISTANCE:
			try_spawn()





