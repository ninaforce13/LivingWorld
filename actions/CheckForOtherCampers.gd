extends CheckConditionAction
export (bool) var inverted = false
export (String) var group
func conditions_met()->bool:
	var nodes = get_tree().get_nodes_in_group(group)	
	if nodes.size() <= 0:
		return always_succeed
	var nearbycamp = get_nearest_node(nodes)
	if !nearbycamp:
		return always_succeed
	var campingdata = nearbycamp.get_node("RecruitData")
	if campingdata:		
		return campingdata.occupants.size() > 1 if not inverted else campingdata.occupants.size() <= 1 
	return .check_conditions(self)

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
