extends MenuDialogAction
var dialogsprite
var tween:Tween
func _ready():
	var pawn = get_pawn()
	dialogsprite = pawn.get_node("ConversationSprite")
	tween = Tween.new()
	add_child(tween)
func _run():
	var valid_option_text:Array = []
	var valid_option_branches:Array = []
	var indices:Array = []
	var default_index:int = - 1

	for i in range(menu_options.size()):
		if i < get_child_count():
			var child = get_child(i)
			if child.has_method("conditions_met"):
				if not child.conditions_met():
					continue
		if default_option == i:
			default_index = valid_option_text.size()
		indices.push_back(i)

		var text = Loc.trf(menu_options[i], MessageDialogAction.create_subs(self))
		if i < formatting.size() and formatting[i] != "":
			text = formatting[i].format([text])
		valid_option_text.push_back(text)

		if i < get_child_count():
			valid_option_branches.push_back(get_child(i))

	if valid_option_text.size() <= 0:
		return false

	var choice = yield (GlobalMenuDialog.show_menu(valid_option_text, default_index), "completed")
	if dialogsprite:
		if dialogsprite.visible:
			tween.interpolate_property(dialogsprite,"rect_position",Vector2(0,0),Vector2(1800,0),0.05,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
	if choice >= 0 and choice < menu_options.size():
		blackboard.choice_text = valid_option_text[choice]
		blackboard.choice_index = indices[choice]
	else :
		blackboard.choice_text = "???"
		blackboard.choice_index = - 1

	yield (GlobalMessageDialog.hide(), "completed")

	if choice >= 0 and choice < valid_option_branches.size():
		var result = wait_for_result(valid_option_branches[choice].run())
		if result is GDScriptFunctionState:
			result = yield (result, "completed")
		return result or always_succeed

	return always_succeed

func _run_children(default_result):
	return default_result
