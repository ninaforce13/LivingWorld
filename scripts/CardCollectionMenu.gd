extends "res://menus/BaseMenu.gd"
const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
const count_label = preload("res://mods/LivingWorld/cardgame/CardCountLabel.tscn")
const deck_button = preload("res://mods/LivingWorld/cardgame/carddeckbutton.tscn")
const duplicate_limit:int = 3
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var focus_button = null
var last_card_focus:int = 0
var last_deck_focus:int = 0
var last_removed_button = null
onready var card_grid = find_node("CardGrid")
onready var deck_grid = find_node("DeckGrid")
onready var add_card_button = find_node("AddCard")
onready var remove_card_button = find_node("RemoveCard")

func _ready():
	focus_mode = Control.FOCUS_NONE
	if !manager.has_savedata():
		manager.initialize_savedata()
	populate_collection()
	populate_deck()
	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")
	set_focus_buttons()
	set_deck_focus_buttons()
	focus_button = card_grid.get_child(0).get_node("Button")
	focus_button.grab_focus()

func _on_focus_changed(control:Control) -> void:
	if control != null:
		if control.name == "CardCollectionMenu":
			focus_button.grab_focus()

func populate_collection():
	var collection = manager.get_card_collection()
	for data in collection.values():
		var card = card_template.instance()
		var label = count_label.instance()
		var new_card = card.duplicate()
		var new_label = label.duplicate()
		new_label.name = "CardCount"
		new_label.get_node("PanelContainer/Control/AmountLabel").text = str(data.amount)
		new_card.form = data.path
		card_grid.add_child(new_card)
		new_card.flip_card_no_anim()
		new_card.add_child(new_label)
		setup_button(new_card)

func populate_deck():
	var collection = manager.get_card_collection()
	for data in collection.values():
		var card = card_template.instance()
		if data.deck > 0:
			add_deck_button(data.path)

func add_deck_button(form_path):
	var new_button = deck_button.instance()
	new_button.monster_form = form_path
	deck_grid.add_child(new_button)
	var button = Button.new()
	button.name = "Button"
	new_button.add_child(button)
	button.focus_mode = Control.FOCUS_ALL
	button.connect("mouse_entered",button,"grab_focus")
	button.connect("mouse_entered",button.get_parent(),"animate_hover_enter")
	button.connect("focus_entered",button.get_parent(),"animate_hover_enter")
	button.connect("focus_entered",self,"disable_add")
	button.connect("focus_entered",self,"set_focus_button",[button])
	button.connect("focus_exited",button.get_parent(),"animate_hover_exit")
	button.connect("focus_exited",self,"set_previous_deck_index",[button])
	button.connect("mouse_exited",button.get_parent(),"animate_hover_exit")
	button.add_stylebox_override("normal",StyleBoxEmpty.new())
	button.add_stylebox_override("pressed",StyleBoxEmpty.new())
	button.add_stylebox_override("hover",StyleBoxEmpty.new())
	button.add_stylebox_override("focus",StyleBoxEmpty.new())

func remove_deck_button(form_path):
	for slot in deck_grid.get_children():
		if slot.monster_form == form_path:
			deck_grid.remove_child(slot)
			break

func setup_button(card):
	var card_button = Button.new()
	card_button.name = "Button"
	card_button.focus_mode = Control.FOCUS_ALL
	card_button.connect("mouse_entered",card_button,"grab_focus")
	card_button.connect("mouse_entered",card,"animate_hover_enter")
	card_button.connect("focus_entered",card,"animate_hover_enter")
	card_button.connect("focus_entered",self,"set_button_state",[card])
	card_button.connect("focus_entered",self,"set_focus_button",[card_button])
	card_button.connect("focus_exited",card,"animate_hover_exit")
	card_button.connect("focus_exited",self,"set_previous_index",[card_button])
	card_button.connect("mouse_exited",card,"animate_hover_exit")
	card_button.add_stylebox_override("normal",StyleBoxEmpty.new())
	card_button.add_stylebox_override("pressed",StyleBoxEmpty.new())
	card_button.add_stylebox_override("hover",StyleBoxEmpty.new())
	card_button.add_stylebox_override("focus",StyleBoxEmpty.new())
	card.add_child(card_button)

func set_previous_index(button):
	last_card_focus = button.get_parent().get_index()

func set_previous_deck_index(button):
	var index = button.get_parent().get_index()
	if button == last_removed_button:
		last_deck_focus =  index + 1 if index + 1 < deck_grid.get_child_count()-1 else index - 1
		last_deck_focus = int(clamp(last_deck_focus,0,INF))
		return
	last_deck_focus = button.get_parent().get_index()

func set_focus_button(button):
	set_deck_focus_buttons()
	set_focus_buttons()
	focus_button = button

func add_to_deck(card):
	var collection = manager.get_card_collection()
	var key = str(card.card_info.name).to_lower()
	var card_data = collection[key]
	if card_data.amount == 0:
		return
	card_data.amount -= 1
	card_data.deck += 1
	set_count_label(card,card_data)
	set_button_state(card)

func remove_card(card):
	var card_data = get_card_collection_data(card)
	if card_data.deck == 0:
		return
	card_data.amount += 1
	card_data.deck -= 1
	set_count_label(card,card_data)
	set_button_state(card)

func _on_AddCard_pressed():
	var card = focus_button.get_parent()
	if focus_button.get_parent().get_parent().name == "DeckGrid":
		return
	add_to_deck(card)
	add_deck_button(card.form)
	set_deck_focus_buttons()

func _on_RemoveCard_pressed():
	var card = focus_button.get_parent()
	if !card.is_inside_tree():
		return
	var is_deck:bool = false
	if focus_button.get_parent().get_parent().name == "DeckGrid":
		var form = card.monster_form
		for child in card_grid.get_children():
			if child.form == form:
				if deck_grid.get_child_count() > 1:
					last_removed_button = focus_button
					focus_button = get_last_deck_focus(last_removed_button)
				else:
					focus_button = get_last_card_focus()
				card = child
				print("Removing %s. Last deck focus index is %s"%[card.card_info.name,last_deck_focus])
				is_deck = true
				break
	remove_card(card)
	remove_deck_button(card.form)
	focus_button.grab_focus()
#	set_deck_focus_buttons()
	if is_deck:
		disable_add()


func get_last_card_focus():
	return card_grid.get_child(last_card_focus).get_node("Button")

func get_last_deck_focus(removed_button):
	var last_button = deck_grid.get_child(last_deck_focus).get_node("Button")
	if last_button == removed_button:
		last_deck_focus = last_deck_focus + 1 if last_deck_focus < deck_grid.get_child_count()-1 else last_deck_focus - 1
		if last_deck_focus < 0:
			last_deck_focus = 0
	last_deck_focus = int(clamp(last_deck_focus,0,INF))
	return deck_grid.get_child(last_deck_focus).get_node("Button")

func set_count_label(card,data):
	var label = card.get_node("CardCount").get_node("PanelContainer/Control/AmountLabel")
	label.text = str(data.amount)

func set_button_state(card):
	var card_data = get_card_collection_data(card)
	var add_disabled:bool = card_data.amount == 0 or card_data.deck == duplicate_limit
	var remove_disabled:bool = card_data.deck == 0
	add_card_button.disabled = add_disabled
	remove_card_button.disabled = remove_disabled

func disable_add():
	add_card_button.disabled = true
	remove_card_button.disabled = false

func get_card_collection_data(card):
	var collection = manager.get_card_collection()
	var key = str(card.card_info.name).to_lower()
	var card_data = collection[key]
	return card_data

func _on_Back_pressed():
	cancel()

func set_focus_buttons():
	var last_card = card_grid.get_child_count()-1
	var first_card = 0

	for slot in card_grid.get_children():
		var index = slot.get_index()
		var end_of_row:bool = (index+1)%5 == 0 and index > 0
		var next_index = index+1 if index < last_card else first_card
		var prev_index = index-1 if index > first_card else last_card
		var up_index = index-5 if index-5 >= first_card else get_looped_index(index,last_card,true)
		var down_index = index+5 if index+5 <= last_card else get_looped_index(index,last_card,false)

		var right_neighbor = deck_grid.get_child(last_deck_focus).get_node("Button") if end_of_row and deck_grid.get_child_count() > 0 else card_grid.get_child(next_index).get_node("Button")
		var left_neighbor = card_grid.get_child(prev_index).get_node("Button")
		var up_neighbor = card_grid.get_child(up_index).get_node("Button")
		var down_neighbor = card_grid.get_child(down_index).get_node("Button")
		var cardbutton = slot.get_node("Button")

		if left_neighbor:
			cardbutton.focus_neighbour_left = left_neighbor.get_path()
		if right_neighbor:
			cardbutton.focus_neighbour_right = right_neighbor.get_path()
		if down_neighbor:
			cardbutton.focus_neighbour_bottom = down_neighbor.get_path()
		if up_neighbor:
			cardbutton.focus_neighbour_top = up_neighbor.get_path()

func set_deck_focus_buttons():
	var last_card = deck_grid.get_child_count()-1
	var first_card = 0

	for slot in deck_grid.get_children():
		var index = slot.get_index()
		var next_index = index+1 if index < last_card else first_card
		var prev_index = index-1 if index > first_card else last_card

		var left_neighbor = card_grid.get_child(last_card_focus).get_node("Button")
		var up_neighbor = deck_grid.get_child(prev_index).get_node("Button")
		var down_neighbor = deck_grid.get_child(next_index).get_node("Button")
		var cardbutton = slot.get_node("Button")

		if left_neighbor:
			cardbutton.focus_neighbour_left = left_neighbor.get_path()
		cardbutton.focus_neighbour_right = cardbutton.get_path()
		if down_neighbor:
			cardbutton.focus_neighbour_bottom = down_neighbor.get_path()
		if up_neighbor:
			cardbutton.focus_neighbour_top = up_neighbor.get_path()

func get_looped_index(index, last_index,backwards:bool)->int:
	var result:int = 0
	var step:int = 0
	if backwards:
		step = 5-(index+1)
		result = last_index-step
	else:
		step = last_index-index
		result = step
	return result
