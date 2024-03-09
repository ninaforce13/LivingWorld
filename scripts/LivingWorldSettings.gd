extends Resource
export (float) var custom_recruit_rate = 0.1
export (float) var partner_rate = 0.1
export (float) var party_disband_rate = 0.1
export (float) var party_form_rate = 0.5
export (float) var holocard_rate = 0.05
export (float) var record_rate = 0.5
export (float) var heal_rate = 0.5
export (float) var coffee_rate = 0.4
export (int) var deck_limit = 30
export (float) var heal_percantage = 0.30
export (float) var fuse_rate = 0.85
export (float) var cards_ai_misplay_rate = 0.45
export (Dictionary) var fly_threshold = {"min":7,"max":INF}
export (Dictionary) var climb_threshold = {"min":4,"max":7}
export (Dictionary) var jump_threshold = {"min":2,"max":4}

export (Dictionary) var levelmap_spawners
const config_path = "user://LivingWorldSettings.cfg"

var config = ConfigFile.new()

