extends PanelContainer

var current_card = null
var card_info:Dictionary = {}
var tween:Tween

func _ready():
	tween = Tween.new()
	add_child(tween)

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

func clear_slot(animate:bool = false,movepos = Vector2.ZERO,duration=0.2):
	if animate and current_card:
		yield(Co.wrap(current_card.animate_playcard(movepos,duration)),"completed")
		yield(Co.wait(0.2),"completed")
	current_card = null
	card_info = {}
	for child in get_children():
		remove_child(child)

func get_card():
	return current_card



