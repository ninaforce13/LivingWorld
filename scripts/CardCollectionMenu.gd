extends "res://menus/BaseMenu.gd"
const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
const count_label = preload("res://mods/LivingWorld/cardgame/CardCountLabel.tscn")
const duplicate_limit:int = 3
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var focus_button = null
onready var card_grid = find_node("CardGrid")
onready var add_card_button = find_node("AddCard")
onready var remove_card_button = find_node("RemoveCard")

func _ready():
	if !manager.has_savedata():
		manager.initialize_savedata()
	populate_collection()
	card_grid.get_child(0).get_node("Button").grab_focus()
	focus_button = card_grid.get_child(0).get_node("Button")
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
		new_card.add_child(new_label)
		setup_button(new_card)

func setup_button(card):
	var card_button = Button.new()
	card_button.name = "Button"
	card_button.focus_mode = Control.FOCUS_ALL
#	card_button.connect("pressed",self,"add_to_deck",[card])
	card_button.connect("mouse_entered",card_button,"grab_focus")
	card_button.connect("mouse_entered",card,"animate_hover_enter")
	card_button.connect("focus_entered",card,"animate_hover_enter")
	card_button.connect("focus_entered",self,"set_button_state",[card])
	card_button.connect("focus_entered",self,"set_focus_button",[card_button])
	card_button.connect("focus_exited",card,"animate_hover_exit")
	card_button.connect("mouse_exited",card,"animate_hover_exit")
	card_button.add_stylebox_override("normal",StyleBoxEmpty.new())
	card_button.add_stylebox_override("pressed",StyleBoxEmpty.new())
	card_button.add_stylebox_override("hover",StyleBoxEmpty.new())
	card_button.add_stylebox_override("focus",StyleBoxEmpty.new())
	card.add_child(card_button)

func set_focus_button(button):
	focus_button = button

func add_to_deck(card):
	var collection = manager.get_card_collection()
	var key = str(card.card_info.name).to_lower()
	var card_data = collection[key]
	if card_data.amount == 0:
		print("Nope, out of cards")
		return
	card_data.amount -= 1
	card_data.deck += 1
	set_count_label(card,card_data)
	set_button_state(card)

func remove_card(card):
	var card_data = get_card_collection_data(card)
	if card_data.deck == 0:
		print("Nothing to remove.")
		return
	card_data.amount += 1
	card_data.deck -= 1
	set_count_label(card,card_data)
	set_button_state(card)
func _on_AddCard_pressed():
	var card = focus_button.get_parent()
	add_to_deck(card)

func _on_RemoveCard_pressed():
	var card = focus_button.get_parent()
	remove_card(card)

func set_count_label(card,data):
	var label = card.get_node("CardCount").get_node("PanelContainer/Control/AmountLabel")
	label.text = str(data.amount)

func set_button_state(card):
	var card_data = get_card_collection_data(card)
	var add_disabled:bool = card_data.amount == 0 or card_data.deck == duplicate_limit
	var remove_disabled:bool = card_data.deck == 0
	add_card_button.disabled = add_disabled
	remove_card_button.disabled = remove_disabled

func get_card_collection_data(card):
	var collection = manager.get_card_collection()
	var key = str(card.card_info.name).to_lower()
	var card_data = collection[key]
	return card_data

func _on_Back_pressed():
	cancel()
