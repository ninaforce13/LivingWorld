extends Action
export (Texture) var emote_icon
export (bool) var enabled
export (Array, Texture) var emotes
export (bool) var use_random = false
export (bool) var random_skip = false
export (int) var skip_rate = 7
func _run():
	var interaction = get_interaction()
	if !interaction:
		return true
		
	interaction.icon_override = emote_icon
	if use_random:
		interaction.icon_override = emotes[randi()%emotes.size()]
	if !enabled or (random_skip and check_skip()):
		MenuHelper.hud.position_markers.remove_interaction(get_pawn())
	else:
		MenuHelper.hud.position_markers.add_interaction(get_pawn())	
	return true

func check_skip()->bool:
	return randi()%10 < skip_rate
func get_interaction():
	return values[0]

