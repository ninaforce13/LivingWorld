extends "res://menus/BaseMenu.gd"
const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
const count_label = preload("res://mods/LivingWorld/cardgame/CardCountLabel.tscn")
const deck_label = preload("res://mods/LivingWorld/cardgame/DeckCountLabel.tscn")
const deck_button = preload("res://mods/LivingWorld/cardgame/carddeckbutton.tscn")
const duplicate_limit:int = 3
const deck_limt:int = 30
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var focus_button = null
var last_card_focus:int = 0
var last_deck_focus:int = 0
var last_removed_button = null
var deck_count:int = 0
onready var card_grid = find_node("CardGrid")
onready var deck_grid = find_node("DeckGrid")
onready var add_card_button = find_node("AddCard")
onready var remove_card_button = find_node("RemoveCard")
onready var deckcountlabel = find_node("DeckCountLabel")
export (bool) var demo = true

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
	var collection
	if !demo:
		collection = manager.get_card_collection().values()
	else:
		collection = get_demo_collection().values()

	collection.sort_custom(self, "_sort_indices")

	for data in collection:
		var card = card_template.instance()
		var label = count_label.instance()
		var decklabel = deck_label.instance()
		var new_card = card.duplicate()
		var collection_label = label.duplicate()
		var deck_label = decklabel.duplicate()
		var load_test = load(data.path)
		if !load_test:
			continue
		collection_label.name = "CardCount"
		deck_label.name = "DeckCount"
		collection_label.get_node("PanelContainer/Control/AmountLabel").text = str(data.amount)
		deck_label.get_node("PanelContainer/Control/AmountLabel").text = str(data.deck)
		new_card.form = data.path
		card_grid.add_child(new_card)
		if data.get("holocard"):
			new_card.holocard = data.holocard
			new_card.set_holoeffect()
		new_card.flip_card_no_anim()
		new_card.add_child(collection_label)
		new_card.add_child(deck_label)
		deck_label.rect_position += Vector2(182.0,0.0)
		setup_button(new_card)

func populate_deck():
	var collection = manager.get_card_collection()
	for data in collection.values():
		if data.deck > 0:
			for _i in range (data.deck):
				add_deck_button(data.path)
	update_deck_count()
func update_deck_count():
	deck_count = deck_grid.get_child_count()
	deckcountlabel.text = "%s/%s"%[deck_count,deck_limt]
	if !deck_full():
		deckcountlabel.add_color_override("font_color",Color.red)
	else:
		deckcountlabel.remove_color_override("font_color")

func add_deck_button(form_path):
	var new_button = deck_button.instance()
	new_button.monster_form = form_path
	deck_grid.add_child(new_button)
	var button = Button.new()
	button.name = "Button"
	new_button.add_child(button)
	button.rect_size = Vector2(268,70)
	button.focus_mode = Control.FOCUS_ALL
	button.connect("mouse_entered",button,"grab_focus")
	button.connect("pressed",self,"_on_RemoveCard_pressed")
	button.connect("mouse_entered",button.get_parent(),"animate_hover_enter")
	button.connect("focus_entered",button.get_parent(),"animate_hover_enter")
	button.connect("focus_entered",self,"disable_add_button")
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
	card_button.connect("pressed",self,"_on_AddCard_pressed")
	card_button.connect("focus_entered",card,"animate_hover_enter")
	card_button.connect("focus_entered",self,"set_button_state",[card])
	card_button.connect("focus_entered",self,"set_focus_button",[card_button])
	card_button.connect("mouse_entered",self,"set_focus_button",[card_button])
	card_button.connect("focus_exited",card,"animate_hover_exit")
	card_button.connect("focus_exited",self,"set_previous_index",[card_button])
	card_button.connect("mouse_exited",self,"set_previous_index",[card_button])
	card_button.connect("mouse_exited",card,"animate_hover_exit")
	card_button.add_stylebox_override("normal",StyleBoxEmpty.new())
	card_button.add_stylebox_override("pressed",StyleBoxEmpty.new())
	card_button.add_stylebox_override("hover",StyleBoxEmpty.new())
	card_button.add_stylebox_override("focus",StyleBoxEmpty.new())
	card.add_child(card_button)
	card_button.rect_size = Vector2(235,300)

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
	if !has_valid_data(card):
		return
	if stockpile_empty(card):
		return

	var card_data = get_card_data(card)
	card_data.amount -= 1
	card_data.deck += 1
	set_count_label(card,card_data)
	set_button_state(card)

func get_card_data(card):
	var collection = manager.get_card_collection()
	var card_form
	if card.get("card_info"):
		card_form = card.card_info.name
	elif card.get("monster_form"):
		var form = load(card.monster_form)
		if !form:
			return null
		else:
			card_form = Loc.tr(form.name)
	else:
		return null
	var key = str(card_form).to_lower()
	var card_data = collection[key]
	return card_data

func remove_card(card):
	if !has_valid_data(card):
		return
	var card_data = get_card_data(card)
	if !exists_in_deck(card):
		return
	card_data.amount += 1
	card_data.deck -= 1
	set_count_label(card,card_data)
	set_button_state(card)

func max_duplicates(card)->bool:
	var card_data = get_card_data(card)
	if !card_data:
		return true
	return card_data.deck == duplicate_limit

func exists_in_deck(card)->bool:
	if !has_valid_data(card):
		return false
	return get_card_data(card).deck > 0

func stockpile_empty(card)->bool:
	var card_data = get_card_data(card)
	if !card_data:
		return true
	return card_data.amount == 0

func _on_AddCard_pressed():
	if deck_full():
		return
	var card = focus_button.get_parent()
	if !has_valid_data(card):
		return
	if stockpile_empty(card):
		return
	if focus_button.get_parent().get_parent().name == "DeckGrid":
		return
	var card_data = get_card_data(card)
	add_to_deck(card)
	add_deck_button(card.form)
	set_deck_focus_buttons()
	set_focus_buttons()
	update_deck_count()

func _on_RemoveCard_pressed():
	var card = focus_button.get_parent()
	if !card.is_inside_tree():
		return
	if !has_valid_data(card):
		return
	if !exists_in_deck(card):
		return

	var card_data = get_card_data(card)
	var is_deck_button:bool = false
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

				is_deck_button = true
				break
	remove_card(card)
	remove_deck_button(card.form)
	update_deck_count()
	focus_button.grab_focus()

	if is_deck_button and deck_grid.get_child_count() > 0:
		disable_add_button()

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
	var decklabel = card.get_node("DeckCount").get_node("PanelContainer/Control/AmountLabel")
	label.text = str(data.amount)
	decklabel.text = str(data.deck)

func has_valid_data(card)->bool:
	var card_data = get_card_data(card)
	return card_data != null

func set_button_state(card):
	if !has_valid_data(card):
		return
	var add_disabled:bool = stockpile_empty(card) or max_duplicates(card)
	var remove_disabled:bool = exists_in_deck(card)
	add_card_button.disabled = add_disabled
	remove_card_button.disabled = remove_disabled

func disable_add_button():
	add_card_button.disabled = true
	remove_card_button.disabled = false

func _on_Back_pressed():
	if !deck_full():
		yield(GlobalMessageDialog.show_message("LIVINGWORLD_UI_DECKCOUNT_ERROR"),"completed")
		return
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

		if last_deck_focus > deck_grid.get_child_count() - 1:
			last_deck_focus = 0
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

func deck_full()->bool:
	return deck_count == deck_limt

func get_demo_collection()->Dictionary:
	var result:Dictionary = {}
	var item:Dictionary = {"path":"","amount":0,"deck":0,"bestiary_index":0,"holocard":false}
	var basic_forms = MonsterForms.basic_forms.values() + MonsterForms.secret_forms.values()
	for form in basic_forms:
		var key = Loc.tr(form.name).to_lower()
		if result.has(key):
			result[key].deck += 1
			continue
		item.path = form.resource_path
		item.amount = 0
		item.deck = 1
		item.bestiary_index = form.bestiary_index
		result[key] = item.duplicate()
		var card:Dictionary = {}
		card["form"] = form.resource_path
		manager.add_card_to_collection(card)
	return result

func _sort_indices(a, b)->bool:

	if (a.bestiary_index < 0) == (b.bestiary_index < 0):
		return a.bestiary_index < b.bestiary_index
	elif a.bestiary_index < 0:
		assert (b.bestiary_index >= 0)
		return false
	else :
		assert (b.bestiary_index < 0)
		assert (a.bestiary_index >= 0)
		return true
