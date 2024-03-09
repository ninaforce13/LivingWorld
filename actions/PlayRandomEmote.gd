extends Action
enum Animations{singing_loop,
				aggro_check,
				aggro_loop,
				aggro_in,
				Happy,
				Angry,
				annoyed,
				content,
				frustrated,
				questioning,
				Sad,
				shocked,
				silly,
				Love,
				tape,
				convo,
				Traffikrab,
				scared,
				battle,
				Trade}
export (Animations) var selection
export (Array,String) var emotes = ["singing_loop",
									"aggro_check",
									"aggro_loop",
									"aggro_in",
									"Happy",
									"Angry",
									"annoyed",
									"content",
									"frustrated",
									"questioning",
									"Sad",
									"shocked",
									"silly",
									"Love",
									"tape",
									"convo",
									"Traffikrab",
									"scared",
									"battle",
									"Trade"]
export (bool) var use_random = false
export (bool) var reset = false
var emote
var random:Random = Random.new()
func _run():

	var whos = get_whos()
	if reset:
		for who in whos:
			who.emote_player.stop()
		return true

	if emotes.size() > selection or (use_random and emotes.size() > 0):
		if use_random:
			emote = random.choice(emotes)
		else:
			emote = emotes[selection]
		var co_list = []
		for who in whos:
				co_list.push_back(who.emote_player.play(emote))
		if co_list.size() > 0:
			yield (Co.join(co_list), "completed")
		for who in whos:
			who.emote_player.stop()
		return true
	return false

func get_whos():
	if values.size() > 0:
		var whos = []
		for value in values:
			if value is Array:
				whos += value
			elif value != null:
				whos.push_back(value)
		return whos
	return [get_pawn()]
