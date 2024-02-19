extends Resource
export (float) var custom_recruit_rate = 0.1
export (float) var partner_rate = 0.1
export (float) var party_disband_rate = 0.1
export (float) var party_form_rate = 0.5
export (float) var holocard_rate = 0.05
export (Dictionary) var levelmap_spawners
const config_path = "user://LivingWorldSettings.cfg"

var config = ConfigFile.new()

