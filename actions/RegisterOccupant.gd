extends Action

export(bool) var register=false
export (bool) var debug_mode=false
func _run():
	var target = values[0]
	if not target:
		return false
	if !is_instance_valid(target):
		return false
	var object_data = target.get_node("ObjectData")
	if !object_data:
		return false
	var pawn = get_pawn()
	var data_node = pawn.get_node("RecruitData")
	if register:
		if object_data.is_full():
			return false
		if data_node.has_party():
			if object_data.has_space(data_node.get_party_size()):
				var party = data_node.get_party_data()
				for member in party:
					var npc = member.node.get_parent()
					object_data.add_occupant(npc)
				object_data.add_occupant(get_pawn())
			else:
				return false
		else:
			object_data.add_occupant(get_pawn())
		if debug_mode:
			print("registered")
		set_bb("object_data", object_data)
	else:
		object_data.remove_occupant(get_pawn())
		if data_node.has_party():
			var party = data_node.get_party_data()
			for member in party:
				var npc = member.node.get_parent()
				object_data.remove_occupant(npc)
	return true

