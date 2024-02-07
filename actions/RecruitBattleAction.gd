extends BattleAction

func _run():
	var e = get_encounter(self, encounter_name_override)
	if e == null:
		push_error("Couldn't find EncounterConfig for BattleAction")
		return false
	var config = e.get_config()
	if has_party():
		var index:int = 0
		for char_config in get_party_configs():
			config.fighters.push_back(char_config.generate_fighter(Random.new(), 0))
			index+=1

	var result = yield (_run_encounter(e, config), "completed")

	return _handle_battle_result(result)

func get_party_configs()->Array:
	var configs:Array
	var pawn = get_pawn()
	var data_node = pawn.get_node("RecruitData")
	if data_node.is_leader:
		var party = data_node.get_party_data()
		for member in party:
			var parent = member.node.get_parent()
			var encounter = parent.get_node("EncounterConfig")
			var charconfig = encounter.get_node("CharacterConfig")
			configs.push_back(charconfig)
	else:
		var leader_node = data_node.get_party_leader()
		var party_lead = leader_node.get_parent()
		var e = party_lead.get_node("EncounterConfig")
		var lead_charconfig = e.get_node("CharacterConfig")
		configs.push_back(lead_charconfig)
		var party = leader_node.get_party_data()
		for member in party:
			if member.node == data_node:
				continue
			var parent = member.node.get_parent()
			var encounter = parent.get_node("EncounterConfig")
			var charconfig = encounter.get_node("CharacterConfig")
			configs.push_back(charconfig)

	return configs

func has_party()->bool:
	var pawn = get_pawn()
	var data_node = pawn.get_node("RecruitData")
	return data_node.has_party()

