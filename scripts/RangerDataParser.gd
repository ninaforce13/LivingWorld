
static func get_directory()->String:
	return "user://arena_archives/"

static func get_current_version()->float:
	return 1.1

static func get_files(dirname:String)->Array:
	var dir = Directory.new()
	if not dir.dir_exists(dirname):
		create_directory(dir, get_directory())
		return []
	var err = dir.open(dirname)
	if err != OK:
		push_error("Cannot open dir " + dirname)
		return []
	dir.list_dir_begin(true, true)
	if err != OK:
		push_error("Cannot list " + dirname)
		return []

	var results = []

	while true:
		var file = dir.get_next()
		if file == "":
			break
		var json = dirname+file
		results.push_back(json)
	dir.list_dir_end()
	return results

static func read_json(files:Array)->Array:
	var parsed_files:Array = []
	for item in files:
		var file = File.new()
		var err = file.open(item, File.READ)
		if err != OK:
			continue
		var content = file.get_as_text()
		var parse = JSON.parse(content)
		if typeof(parse.result) == TYPE_DICTIONARY:
			parse.result["filepath"] = item
			parsed_files.append(parse.result)
		else:
			push_error("Living World Mod: Failed to parse: " + item)
		file.close()
	parsed_files = remove_broken_data(parsed_files)
	return parsed_files

static func append_json(ranger_dict:Dictionary, filepath:String, folder_name:String = get_directory())->bool:
	var file = File.new()
	var dir = Directory.new()
	if directory_missing(dir, folder_name):
		create_directory(dir, folder_name)
	version_tag_file(ranger_dict)
	print("Living World Mod: Attempting to edit file: " + filepath)
	var result = file.open(filepath, File.WRITE)
	if result != OK:
		push_error("Living World Mod: Failed to save file: " + filepath)
		return false
	file.store_string(JSON.print(ranger_dict, "\t"))
	file.close()
	print("Living World Mod: Successfully appended file: " + filepath)
	return true

static func save_json(ranger_dict:Dictionary, folder_name:String = get_directory())->bool:
	var file = File.new()
	var dir = Directory.new()
	var filename = ranger_dict.name
	var divider = "/"
	var extension = ".json"
	var duplicate_filename:bool = true
	var pass_index:int = 1
	if directory_missing(dir, folder_name):
		create_directory(dir, folder_name)
	version_tag_file(ranger_dict)
	while duplicate_filename:
		if file.file_exists(folder_name+divider+filename+extension):
			var tagon = "("+str(pass_index)+")"
			if not file.file_exists(folder_name+divider+filename+tagon+extension):
				filename = filename+tagon
				duplicate_filename = false
			pass_index += 1
		if not file.file_exists(folder_name+divider+filename+extension):
			duplicate_filename = false
	print("Living World Mod: Attempting to save file: " + filename+extension)
	var result = file.open(folder_name+divider+filename+extension, File.WRITE)
	if result != OK:
		push_error("Living World Mod: Failed to save file: " + filename+extension + " in " + folder_name)
		return false
	file.store_string(JSON.print(ranger_dict, "\t"))
	file.close()
	print("Living World Mod: Successfully created file: " + filename+extension + " in " + folder_name)
	return true

static func version_tag_file(file:Dictionary):
	file["version"] = get_current_version()

static func create_directory(dir:Directory, folder:String):
	print("Living World Mod: " + folder+" does not exist. Attempting to create folder.")
	var result = dir.make_dir(folder)
	if result != OK:
		push_error("Living World Mod: Failed to create folder "+folder)
		return false

static func directory_missing(dir:Directory, dir_path:String)->bool:
	return not dir.dir_exists(dir_path)

static func remove_broken_data(collection:Array)->Array:
	var key_fields:Array = ["name","human_part_names", "human_colors", "pronouns","introdialog","defeatdialog","biotext", "recruiter","recruiter_id","version"]
	var tape_fields:Array = ["tape0","tape1","tape2","tape3","tape4","tape5"]
	var tape_data_fields:Array = ["name", "hp", "form", "grade","exp_points","seed_value","type_override","type_native", "stickers", "stat_increments", "favorite"]
	var sticker_fields:Array = ["sticker","rarity","attributes"]
	var record_count:int = 0
	var valid_records:Array = []
	for record in collection:
		record_count += 1
		var invalid_record:bool = false
		for key in key_fields:
			if not record.has(key):
				push_error("Living World Mod: Failed to find key " + key + " in record " + str(record_count))
				invalid_record = true
#
		var tape_count:int = 1
		for tape_field in tape_fields:
			if record.has(tape_field):
				for tape_data_field in tape_data_fields:
					if not record[tape_field].has(tape_data_field):
						push_error("Living World Mod: Failed to find key " + tape_data_field + " in record " + str(record_count))
						invalid_record = true
#
					if tape_data_field == "stickers":
						if not record[tape_field].has(tape_data_field):
							push_error("Living World Mod: Failed to find key " + tape_data_field + " in record " + str(record_count))
							invalid_record = true
						if record[tape_field].has(tape_data_field):
							if not record[tape_field].get(tape_data_field) is Array:
								push_error("Living World Mod: [Stickers] is not valid type Array. Record " + str(record_count))
								invalid_record = true
							else:
								var sticker_count:int = 1
								for sticker in record[tape_field].get(tape_data_field):
									if not sticker is Dictionary and sticker != null:
										push_error("Living World Mod: sticker# "+ str(sticker_count) +" in tape# "+ str(tape_count)+" is not valid type Dictionary. Record " + str(record_count))
										invalid_record = true
									elif sticker != null:
										for sticker_field in sticker_fields:
											if not sticker.has(sticker_field):
												push_error("Living World Mod: Failed to find key " + sticker_field + " in sticker# "+ str(sticker_count) +" in tape# "+ str(tape_count)+ " in record# " + str(record_count))
												invalid_record = true
									sticker_count+=1

				if monster_validation(record[tape_field]):
					tape_count += 1

		if tape_count < 3:
			push_error("Living World Mod: Not enough tapes. Tape count: " + str(tape_count) + " in record " + str(record_count))
			invalid_record = true

		if not invalid_record:
			valid_records.push_back(record)

	return valid_records

static func monster_validation(tape_snapshot:Dictionary)->bool:
	var tape = MonsterTape.new()
	tape_snapshot = get_custom_monster(tape_snapshot)
	return tape.set_snapshot(tape_snapshot, 1)


static func get_custom_monster(tape_snapshot:Dictionary)->Dictionary:
	if tape_snapshot.has("custom_form"):
		if tape_snapshot.custom_form != "":
			var form = load(tape_snapshot.custom_form) as MonsterForm
			if form:
				tape_snapshot.form = tape_snapshot.custom_form
				print("Living World Mod: Retrieved custom form " + tape_snapshot.custom_form)
	return tape_snapshot

static func set_custom_monster(tape_snapshot:Dictionary)->Dictionary:
	if tape_snapshot["form"].begins_with("res://mods/") or tape_snapshot["form"].begins_with("res://data/monster_forms/mods_"):
		tape_snapshot["custom_form"] = tape_snapshot["form"]
		tape_snapshot["form"] =  "res://data/monster_forms/traffikrab.tres"
		print("Living World Mod: Set fallback form for custom form: " + tape_snapshot.custom_form)
	return tape_snapshot

static func set_char_config(char_config:CharacterConfig, ranger_data, tapes:Array = []):
	var randomtapeconfig = preload("res://mods/LivingWorld/scripts/RandomTapeConfig.gd")

	char_config.character_name = ranger_data.name
	char_config.pronouns = ranger_data.pronouns
	var char_stats:Character = Character.new()
	if ranger_data.has("stats"):
		if ranger_data["stats"] != null:
			if ranger_data["stats"].size() > 0:
				char_stats.set_snapshot(ranger_data["stats"],1)
		else:
			char_config.base_character.base_max_hp = 120
	char_config.human_colors = ranger_data.human_colors if typeof(ranger_data.human_colors) == TYPE_DICTIONARY else JSON.parse(ranger_data.human_colors).result
	char_config.human_part_names = ranger_data.human_part_names if typeof(ranger_data.human_part_names) == TYPE_DICTIONARY else JSON.parse(ranger_data.human_part_names).result
	char_stats.name = ranger_data.name
	char_config.base_character = char_stats
	if not ranger_data.has("stats"):
		char_config.base_character.base_max_hp = 120
	var index:int = 0
	for key in ranger_data:
		if str(key) == "tape"+str(index):
			if ranger_data[key].favorite:
				tapes[index].tape_snapshot = get_custom_monster(ranger_data[key])
				var snapshot = get_custom_monster(ranger_data[key])
				var form = load(snapshot.form)
				if form:
					char_config.base_character.partner_signature_species = form
			else:
				tapes[index].tape_snapshot = get_custom_monster(ranger_data[key])
			index += 1

static func set_npc_appearance(npc:NPC, ranger_data):
	var colors:Dictionary = ranger_data.human_colors if typeof(ranger_data.human_colors) == TYPE_DICTIONARY else JSON.parse(ranger_data.human_colors).result
	var parts:Dictionary = ranger_data.human_part_names if typeof(ranger_data.human_part_names) == TYPE_DICTIONARY else JSON.parse(ranger_data.human_part_names).result
	npc.set_sprite_colors(colors)
	npc.set_sprite_part_names(parts)

static func get_empty_recruit()->Dictionary:
	var recruit:Dictionary = {"appearance":{}, "tapes":{}, "stats":{}, "filepath":""}
	var parts = {}
	var colors = {}
	HumanLayersHelper.randomize_sprite(null, parts, colors)
	recruit = {"name":"Trainee",
				"human_part_names":to_json(parts),
				"human_colors":to_json(colors),
				"pronouns":2,
				"introdialog":"Hello!",
				"defeatdialog":"Argh!",
				"biotext":"Random Recruit",
				"recruiter":SaveState.party.player.name,
				"recruiter_id":SaveState.get_ranger_id(),
				"tapes":{},
				"stats":{},
				"filepath":""}

	return recruit
