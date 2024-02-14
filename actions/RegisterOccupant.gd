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
	var state = get_parent().name
	var data_node = pawn.get_node("RecruitData")
	if register:
		if object_data.is_full() and object_data.get_own_slot(get_pawn()) == null:
			return false
		if object_data.get_own_slot(get_pawn()):
			return true
		if data_node.has_party():

			if object_data.has_space(data_node.get_party_size()):
				var party = data_node.get_party_data()
				for member in party:
					var npc = member.node.get_parent()
					object_data.add_occupant(npc)
					npc.get_behavior().set_state(state)

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
				if !member.node.is_leader:
					set_interaction(npc)
					npc.get_behavior().set_state("Party")
			if !data_node.is_leader:
				set_interaction(pawn)
				pawn.get_behavior().set_state("Party")
	return true

func set_interaction(pawn):
	var interaction = pawn.get_node("Interaction")
	if interaction:
		interaction.disabled = false

