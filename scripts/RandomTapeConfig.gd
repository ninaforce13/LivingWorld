extends TapeConfig

export (bool) var seeded:bool = false
export (String) var seed_key:String = ""
export (float) var bootleg_rate:float = 0.001
export (float) var rare_sticker_rate:float = 0.3
export (float) var random_sticker_rate:float = 0.5

export (Resource) var spawn_profile:Resource
export (float) var profile_evolution_rate:float = 0.1
export (float) var non_profile_rate:float = 0.01
const ExtraSlot = preload("res://data/sticker_attributes/extra_slot.tres")

func _configure_tape(tape:MonsterTape, rand:Random, exp_points:int):
	pass
	
func _generate_tape(encounter_rand:Random, defeat_count:int)->MonsterTape:
	var tape = ._generate_tape(encounter_rand, defeat_count)
	var rand:Random
	if not seeded:
		rand = Random.new()
	else :
		if seed_key == "":
			rand = encounter_rand
		else :
			rand = encounter_rand.get_child(seed_key)
	
	if form:
		assert (tape.form != null)
	if tape.form == null:
		tape.form = _rand_form(rand)
		form = tape.form
	if rand.rand_bool(profile_evolution_rate):
		var evos = []
		for evolution in tape.form.evolutions:
			if not evolution.is_secret:
				evos.push_back(evolution.evolved_form)
		if evos.size() > 0:
			tape.form = rand.choice(evos)
	
	if tape.type_override.size() == 0 and bootleg_rate > 0.0 and rand.rand_float() < bootleg_rate:
		tape.type_override = [BattleSetupUtil.random_type(rand)]
	configure_stickers(tape)
	return tape

func configure_stickers(tape:MonsterTape):	
	tape.assign_initial_stickers(true)
	tape.upgrade_to(5, Random.new())	
	
	var maxslots = tape.form.move_slots
	var extra_slots:int = 0
	for upgrade in tape.form.tape_upgrades:
		if upgrade is TapeUpgradeMove:
			if upgrade.add_slot:
				maxslots += 1
				
	if tape.stickers.size() > maxslots:			
		var remove_count = tape.stickers.size() - maxslots
		for _i in range (remove_count):
			var sticker = tape.stickers[randi()%tape.stickers.size()]
			tape.stickers.erase(sticker)

	var duplicates:Dictionary = {}
	for sticker in tape.stickers:
		if duplicates.has(sticker.battle_move):			
			tape.stickers.erase(duplicates[sticker.battle_move])
		if not duplicates.has(sticker.battle_move):			
			duplicates[sticker.battle_move] = sticker	
	
	while tape.stickers.size() < maxslots:
		var new_sticker:Array = generate_stickers(Random.new(),tape.form.move_tags, 1, true)			
		if not duplicates.has(new_sticker[0].battle_move):
			tape.stickers.push_back(new_sticker[0])
			duplicates[new_sticker[0].battle_move] = new_sticker[0]
	var new_stickers:Array = []
	for sticker in tape.stickers:		
		if random_sticker_applied():		
			var new_sticker:Array  = generate_stickers(Random.new(),tape.form.move_tags, 1, true)						
			if not duplicates.has(new_sticker[0].battle_move):			
				duplicates.erase(sticker.battle_move)
				duplicates[new_sticker[0].battle_move] = new_sticker[0]
				sticker = new_sticker[0]
		if rare_sticker_applied() and move_is_upgradable(sticker.battle_move):
			sticker = upgrade_sticker(sticker)
			if rare_sticker_applied() and move_is_upgradable(sticker.battle_move):
				sticker = upgrade_sticker(sticker)
		new_stickers.push_back(sticker)

	for sticker in new_stickers:
		for attribute in sticker.attributes:			
			if attribute.get_script() == ExtraSlot.get_script():
				extra_slots += 1
	while extra_slots > 0:		
		var new_sticker:Array  = generate_stickers(Random.new(),tape.form.move_tags, 1, false)	
		if duplicates.has(new_sticker[0].battle_move):	
			continue
		for attribute in new_sticker[0].attributes:
			if attribute.get_script() == ExtraSlot.get_script():
				extra_slots += 1											
		new_stickers.push_back(new_sticker[0])
		duplicates[new_sticker[0].battle_move] = new_sticker[0]
		extra_slots -= 1
	
	var has_attack:bool = false
	for sticker in new_stickers:
		if sticker.battle_move.power > 0:
			has_attack = true
			break		

	while not has_attack:
		var new_sticker:Array = generate_stickers(Random.new(),tape.form.move_tags, 1, false)						
		if not duplicates.has(new_sticker[0].battle_move) and new_sticker[0].battle_move.power > 0:			
			new_stickers.remove(randi()%new_stickers.size())
			new_stickers.push_back(new_sticker[0])
			has_attack = true
			
		
	tape.stickers = new_stickers.duplicate()
	
func generate_stickers(rand:Random, sticker_tags, max_num:int = - 1, suppress_upgrade:bool = false)->Array:
	var stickers = []
	var moves:Array = []
	for tag in sticker_tags:
		moves += BattleMoves.get_moves_for_tag(tag)
	
	assert (moves.size() > 0)
	if moves.size() == 0:
		return []
	
	for _i in range(max_num):
		if moves.size() == 0:
			break
		var move = rand.choice(moves)
		moves.erase(move)
		var item = ItemFactory.generate_item(move, rand)
		assert (item != null)
		
		if rare_sticker_applied() and not suppress_upgrade and move_is_upgradable(move):
			item = ItemFactory.upgrade_rarity(item, rand)
			assert (item != null)
			assert (item.rarity >= BaseItem.Rarity.RARITY_UNCOMMON)
		
		stickers.push_back(item)
	
	return stickers	

func random_sticker_applied()->bool:
	return randf() < random_sticker_rate

func bootleg_tape_applied()->bool:
	return randf() < bootleg_rate

func rare_sticker_applied()->bool:
	return randf() < rare_sticker_rate

func upgrade_sticker(sticker):
	return ItemFactory.upgrade_rarity(sticker, Random.new())

func move_is_upgradable(move:BattleMove)->bool:
	return move.attribute_profile != null

func _rand_form(rand:Random)->MonsterForm:
	
	rand = rand.get_child("_rand_form")
	var sp = spawn_profile if spawn_profile is MonsterSpawnProfile else WorldSystem.current_spawn_profile
	assert (sp == null or sp is MonsterSpawnProfile)
	if not (sp is MonsterSpawnProfile) or rand.rand_float() < non_profile_rate:
		var form = SaveState.species_collection.get_random_seen_spawnable_species(rand)
		if form != null:
			return form
	return sp.choose_form(rand)
