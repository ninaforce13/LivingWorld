extends Control
const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
onready var OpponentHandGrid = find_node("OpponentHandGrid")
onready var PlayerHandGrid = find_node("PlayerHandGrid")
export (Dictionary) var player_setup
export (Dictionary) var enemy_setup
func _ready():
	for _i in range (0,5):
		var card = card_template.instance()
		card.bordercolor = player_setup.bordercolor
		card.bandcolor = player_setup.bandcolor
		card.offscreen_pos = player_setup.offscreen_pos
		PlayerHandGrid.add_child(card)
		yield(Co.wait(0.1),"completed")
		card.animate_entry()
	for _i in range (0,5):
		var card = card_template.instance()
		card.bordercolor = enemy_setup.bordercolor
		card.bandcolor = enemy_setup.bandcolor
		card.offscreen_pos = enemy_setup.offscreen_pos
		OpponentHandGrid.add_child(card)
		yield(Co.wait(0.1),"completed")
		card.animate_entry()
