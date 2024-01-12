extends Resource
export (float) var custom_recruit_rate = 0.1
export (float) var partner_rate = 0.1
export (Dictionary) var levelmap_spawners
const config_path = "user://LivingWorldSettings.cfg"

var config = ConfigFile.new()

