extends Spawner
export (bool) var only_npc = true
var npcmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")

func try_spawn():
	var max_spawns = day_max_spawns if WorldSystem.time.is_day() else night_max_spawns
	if current_spawns.size() >= max_spawns:
		return null

	for _i in range(max_attempts):
		var node = _try_spawn_attempt(null)
		if node is GDScriptFunctionState:
			node = yield (node, "completed")
		if node != null:
			return node
		yield (Co.next_frame(), "completed")
		if not is_inside_tree():
			return null
	return null


func _try_spawn_attempt(config):
	assert (is_inside_tree())
	if not is_inside_tree():
		return null
	
	var pos = Vector3(rand.rand_float(), rand.rand_float(), rand.rand_float()) * aabb.size + aabb.position
	var global_pos = global_transform.xform(pos)
	
	for player in WorldSystem.get_players():
		if global_pos.distance_to(player.global_transform.origin) < MIN_DISTANCE_TO_PLAYER:
			return null
	var node:Node = Node.new()
	var npc = npcmanager.create_npc(self,self)
	if npc:
		npc.transform.origin = pos
		current_spawns.push_back(npc)
		return npc
	return null	
	
	
	
