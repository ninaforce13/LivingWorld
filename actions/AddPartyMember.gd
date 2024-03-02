extends Action

func _run():
	var target = values[0]
	if target:
		var pawn = get_pawn()
		if pawn.has_method("get_data"):
			var data = pawn.get_data()
			if !data.party_full() and data.has_party():
				var party = data.get_party_data()
				for member in party:
					member.node.add_party_member(target.get_data(), target.get_data().recruit)
					target.get_data().add_party_member(member.node,member.data,member.leader)
					if member.leader:
						target.get_data().follow_target = member.node.get_parent()
						target.get_behavior().set_state("Party")
			if !data.has_party():
				data.conversation_partners.push_back(target)
				target.get_data().conversation_partners.push_back(pawn)
				data.form_party()
				target.get_behavior().set_state("Party")
	return true
