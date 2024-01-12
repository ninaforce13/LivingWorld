extends PanelContainer

onready var inputs = find_node("Inputs")
onready var JoinEncountersInput = find_node("JoinEncountersInput")
onready var UseMagnetismInput = find_node("UseMagnetismInput")
onready var PopulationInput = find_node("PopulationInput")
onready var UseCustomRecruitsInput = find_node("UseCustomRecruitsInput")
onready var CaptainPatrolInput = find_node("CaptainPatrolInput")
const settings_path = "user://LivingWorldSettings.cfg"

func _ready():
	reset()

func is_dirty()->bool:
	var config = _load_settings_file()
	if JoinEncountersInput.selected_value != get_config_value("join_raids"):
		return true

	if UseMagnetismInput.selected_value != get_config_value("use_magnetism"):
		return true

	if PopulationInput.selected_value != get_config_value("population"):
		return true

	if UseCustomRecruitsInput.selected_value != get_config_value("custom_trainee"):
		return true

	if CaptainPatrolInput.selected_value != get_config_value("captain_patrol"):
		return true

	return false

func apply():
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("battle", "join_raids", JoinEncountersInput.selected_value)
	config.set_value("world", "population", PopulationInput.selected_value)
	config.set_value("behavior", "magnetism", UseMagnetismInput.selected_value)
	config.set_value("behavior", "captain_patrol", CaptainPatrolInput.selected_value)
	config.set_value("world", "custom_trainee", UseCustomRecruitsInput.selected_value)

	_save_settings_file(config)

func _save_settings_file(config:ConfigFile):

	if config.save(settings_path) != OK:
		push_error("Unable to save settings file " + settings_path)

func reset():
	JoinEncountersInput.selected_value = get_config_value("join_raids")
	UseMagnetismInput.selected_value = get_config_value("use_magnetism")
	PopulationInput.selected_value = get_config_value("population")
	UseCustomRecruitsInput.selected_value = get_config_value("custom_trainee")
	CaptainPatrolInput.selected_value = get_config_value("captain_patrol")

	inputs.setup_focus()

func get_config_value(setting_name:String):
	var config:ConfigFile = _load_settings_file()
	var value
	if setting_name == "join_raids":
		value = config.get_value("battle","join_raids",JoinEncountersInput.values[0])
	if setting_name == "use_magnetism":
		value = config.get_value("behavior","magnetism",UseMagnetismInput.values[0])
	if setting_name == "population":
		value = config.get_value("world","population",PopulationInput.values[0])
	if setting_name == "custom_trainee":
		value = config.get_value("world","custom_trainee",UseCustomRecruitsInput.values[0])
	if setting_name == "captain_patrol":
		value = config.get_value("world","custom_trainee",CaptainPatrolInput.values[0])
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
