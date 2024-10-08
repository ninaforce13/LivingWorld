extends PanelContainer

onready var inputs = find_node("Inputs")
onready var JoinEncountersInput = find_node("JoinEncountersInput")
onready var UseMagnetismInput = find_node("UseMagnetismInput")
onready var UseVineballInput = find_node("UseVineballInput")
onready var PopulationInput = find_node("PopulationInput")
onready var UseCustomRecruitsInput = find_node("UseCustomRecruitsInput")
onready var CaptainPatrolInput = find_node("CaptainPatrolInput")
onready var BackupStatusInput = find_node("BackupStatusInput")
onready var UseBattleSpriteInput = find_node("UseBattleSpriteInput")
onready var CardEnemyThoughtsInput = find_node("CardEnemyThoughtsInput")
onready var OverspillInput = find_node("OverspillInput")
onready var UseItemsInput = find_node("UseItemsInput")
onready var RecordableInput = find_node("RecordableInput")
const settings_path = "user://LivingWorldSettings.cfg"

func _ready():
	reset()

func is_dirty()->bool:
	var config = _load_settings_file()
	if JoinEncountersInput.selected_value != get_config_value("join_raids"):
		return true

	if UseMagnetismInput.selected_value != get_config_value("use_magnetism"):
		return true
	if UseVineballInput.selected_value != get_config_value("use_vineball"):
		return true

	if PopulationInput.selected_value != get_config_value("population"):
		return true

	if UseCustomRecruitsInput.selected_value != get_config_value("custom_trainee"):
		return true

	if CaptainPatrolInput.selected_value != get_config_value("captain_patrol"):
		return true

	if UseBattleSpriteInput.selected_value != get_config_value("battle_sprite"):
		return true

	if BackupStatusInput.selected_value != get_config_value("backup_status"):
		return true

	if CardEnemyThoughtsInput.selected_value != get_config_value("enemy_thinking"):
		return true

	if OverspillInput.selected_value != get_config_value("overspill_damage"):
		return true

	if RecordableInput.selected_value != get_config_value("npcs_recording"):
		return true

	if UseItemsInput.selected_value != get_config_value("use_items"):
		return true

	return false

func apply():
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("battle", "join_raids", JoinEncountersInput.selected_value)
	config.set_value("battle", "backup_status", BackupStatusInput.selected_value)
	config.set_value("battle", "overspill_damage", OverspillInput.selected_value)
	config.set_value("battle", "npcs_recording", RecordableInput.selected_value)
	config.set_value("battle", "use_items", UseItemsInput.selected_value)
	config.set_value("world", "population", PopulationInput.selected_value)
	config.set_value("behavior", "magnetism", UseMagnetismInput.selected_value)
	config.set_value("behavior", "vineball", UseVineballInput.selected_value)
	config.set_value("behavior", "captain_patrol", CaptainPatrolInput.selected_value)
	config.set_value("world", "custom_trainee", UseCustomRecruitsInput.selected_value)
	config.set_value("world", "battle_sprite", UseBattleSpriteInput.selected_value)
	config.set_value("card", "enemy_thinking", CardEnemyThoughtsInput.selected_value)

	_save_settings_file(config)

func _save_settings_file(config:ConfigFile):

	if config.save(settings_path) != OK:
		push_error("Unable to save settings file " + settings_path)

func reset():
	JoinEncountersInput.selected_value = get_config_value("join_raids")
	UseMagnetismInput.selected_value = get_config_value("use_magnetism")
	UseVineballInput.selected_value = get_config_value("use_vineball")
	PopulationInput.selected_value = get_config_value("population")
	UseCustomRecruitsInput.selected_value = get_config_value("custom_trainee")
	CaptainPatrolInput.selected_value = get_config_value("captain_patrol")
	BackupStatusInput.selected_value = get_config_value("backup_status")
	UseBattleSpriteInput.selected_value = get_config_value("battle_sprite")
	CardEnemyThoughtsInput.selected_value = get_config_value("enemy_thinking")
	OverspillInput.selected_value = get_config_value("overspill_damage")
	RecordableInput.selected_value = get_config_value("npcs_recording")
	UseItemsInput.selected_value = get_config_value("use_items")

	inputs.setup_focus()

func get_config_value(setting_name:String):
	var config:ConfigFile = _load_settings_file()
	var value
	if setting_name == "npcs_recording":
		value = config.get_value("battle","npcs_recording",RecordableInput.values[0])
	if setting_name == "use_items":
		value = config.get_value("battle","use_items",UseItemsInput.values[0])
	if setting_name == "join_raids":
		value = config.get_value("battle","join_raids",JoinEncountersInput.values[0])
	if setting_name == "use_vineball":
		value = config.get_value("behavior","vineball",UseVineballInput.values[0])
	if setting_name == "use_magnetism":
		value = config.get_value("behavior","magnetism",UseMagnetismInput.values[0])
	if setting_name == "population":
		value = config.get_value("world","population",PopulationInput.values[0])
	if setting_name == "custom_trainee":
		value = config.get_value("world","custom_trainee",UseCustomRecruitsInput.values[0])
	if setting_name == "battle_sprite":
		value = config.get_value("world","battle_sprite",UseBattleSpriteInput.values[0])
	if setting_name == "captain_patrol":
		value = config.get_value("behavior","captain_patrol",CaptainPatrolInput.values[0])
	if setting_name == "backup_status":
		value = config.get_value("battle","backup_status",BackupStatusInput.values[0])
	if setting_name == "enemy_thinking":
		value = config.get_value("card","enemy_thinking",CardEnemyThoughtsInput.values[0])
	if setting_name == "overspill_damage":
		value = config.get_value("battle","overspill_damage",OverspillInput.values[0])
	return value

func grab_focus():
	inputs.grab_focus()

func _load_settings_file()->ConfigFile:

	var config = ConfigFile.new()
	var file = File.new()
	if file.file_exists(settings_path):
		if config.load(settings_path) != OK:
			push_error("Unable to load settings file " + settings_path)
	return config
