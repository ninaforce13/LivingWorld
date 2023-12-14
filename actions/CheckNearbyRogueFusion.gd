extends CheckConditionAction

export (float) var within_distance = 10.0
export (bool) var inverted = false
export (String) var group:String
export (float) var delay = 1.0

func run():
	if delay > 0.0:
		yield(Co.wait(delay),"completed")
	if not conditions_met():
		return always_succeed
	return .run()

func conditions_met()->bool:
	if root == null:
		setup()
	var nodes = get_tree().get_nodes_in_group(group)		
	var target = get_nearest_node(nodes)
	if check_conditions(self):
		var global_pos = get_pawn().global_transform.origin
		if target:	
			if inverted:	
				return !global_pos.distance_to(target.global_transform.origin) < within_distance
			else:
				return global_pos.distance_to(target.global_transform.origin) < within_distance
	return check_conditions(self)

			
func get_nearest_node(nodes):
	if not (get_pawn() is Spatial):
		return null
	var pawn_pos = get_pawn().global_transform.origin
	var best = null
	var best_dist = INF
	for node in nodes:
		if node == get_pawn():
			continue
		var dist = node.global_transform.origin.distance_to(pawn_pos)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best
