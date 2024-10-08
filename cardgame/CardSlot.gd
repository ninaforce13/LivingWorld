extends PanelContainer

var current_card = null
var card_info:Dictionary = {}

func set_card(card):
	var old_slot = card.get_parent()
	if old_slot:
		old_slot.clear_slot()
	add_child(card)
	current_card = card
	set_card_info(card.card_info)
	pass

func set_card_info(info:Dictionary):
	card_info = info.duplicate()

func occupied()->bool:
	return current_card != null

func clear_slot():
	current_card = null
	card_info = {}
	for child in get_children():
		remove_child(child)

func animate_move(movepos = Vector2.ZERO,duration=0.2):
	if current_card:
		current_card.animate_playcard(movepos,duration)
		yield(current_card.tween,"tween_all_completed")

func get_card():
	return current_card



