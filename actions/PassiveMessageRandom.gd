extends Action

export (Array, String) var messages = []
export (String) var speaker_name:String
export (bool) var use_pawn_npc_name:bool = true
export (bool) var wait_until_finished:bool = true
export (bool) var captain_specific:bool = false
export (Array,Dictionary) var captain_messages = [{"captain_name":"","message":""}]
var random:Random = Random.new()
func _run():
	var speaker = ""

	var pawn = get_pawn()
	if use_pawn_npc_name and pawn != null:
		var npc_name = pawn.get("npc_name")
		if npc_name != null and npc_name != "":
			speaker = pawn.get("npc_name")
	if captain_specific:
		var npc_name = pawn.get("npc_name")
	var text
	var subs = MessageDialogAction.create_subs(self)
	if captain_specific:
		var npc_name = pawn.get("npc_name")
		var new_message:String
		for entry in captain_messages:
			if Loc.tr(entry["captain_name"]) == Loc.tr(npc_name):
				new_message = entry["message"]
				break
		if new_message:
			text = Loc.trf(new_message, subs)
		else:
			text = Loc.trf(random.choice(messages), subs)
	else:
		text = Loc.trf(random.choice(messages), subs)

	if speaker == "":
		speaker = Loc.trf(speaker_name, subs)

	var co = GlobalMessageDialog.passive_message.show_message(text, speaker)
	if wait_until_finished:
		yield (Co.safe_yield(self, co), "completed")
	return true
