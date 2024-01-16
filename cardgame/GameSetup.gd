extends Control
signal enemyturn

const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")

onready var OpponentHandGrid = find_node("OpponentHandGrid")
onready var PlayerHandGrid = find_node("PlayerHandGrid")
onready var PlayerField = find_node("PlayerField")
onready var EnemyField = find_node("EnemyField")
onready var EnemyHealth = find_node("EnemyHealth")
onready var PlayerHealth = find_node("PlayerHealth")
onready var EnemyState = find_node("EnemyState")
onready var PlayerState = find_node("PlayerState")
onready var PlayerDeck = find_node("PlayerDeck")
onready var EnemyDeck = find_node("EnemyDeck")

export (Dictionary) var player_setup
export (Dictionary) var enemy_setup
export (int) var deck_seed

enum State {ATTACK,DEFENSE,NEUTRAL}
enum Team  {PLAYER,ENEMY}
var random:Random
var player_deck:Array = []
var enemy_deck:Array = []
var player_turn:bool = false
var player_entry_point
var enemy_entry_point
var player_stats:Dictionary = {"max_hp":3,"hp":3,"state":State.NEUTRAL,"attack":0,"defense":0}
var enemy_stats:Dictionary = {"max_hp":3,"hp":3,"state":State.NEUTRAL,"attack":0,"defense":0}

func _ready():
	if deck_seed != 0:
		random = Random.new(deck_seed)
	else:
		random = Random.new()

	player_deck = build_demo_deck(0)
	enemy_deck = build_demo_deck(1)
	yield(Co.wait(1),"completed")
	for _i in range (0,5):
		yield(Co.wrap(draw_card(Team.PLAYER)),"completed")
	for _i in range (0,5):
		yield(Co.wrap(draw_card(Team.ENEMY)),"completed")

	connect("enemyturn",self,"enemy_move")
	GlobalMessageDialog.passive_message.show_message("Your Turn")
	set_player_turn(true)

func set_card_colors(card,team):
	var setup = player_setup if team == Team.PLAYER else enemy_setup
	card.bordercolor = setup.bordercolor
	card.bandcolor = setup.bandcolor

func ready_to_resolve()->bool:
	var result:bool = true
	for slot in EnemyField.get_children():
		if !slot.occupied():
			result = false
			break
	for slot in PlayerField.get_children():
		if !slot.occupied():
			result = false
	return result

func resolve_field():
	var winner
	var loser
	var chosen_player_stat = get_wield_stat(player_stats)
	var chosen_enemy_stat = get_wield_stat(enemy_stats)

	if chosen_player_stat > chosen_enemy_stat:
		enemy_stats.hp -= 1
		EnemyHealth.text = str(enemy_stats.hp)
		GlobalMessageDialog.passive_message.show_message("Round Winner: Player")

	if chosen_player_stat < chosen_enemy_stat:
		player_stats.hp -= 1
		PlayerHealth.text = str(player_stats.hp)
		GlobalMessageDialog.passive_message.show_message("Round Winner: Enemy")
	if chosen_player_stat == chosen_enemy_stat:
		GlobalMessageDialog.passive_message.show_message("Draw")

	clear_battlefield()
	reset_stats()

func clear_battlefield():
	for slot in EnemyField.get_children():
		slot.clear_slot()
	for slot in PlayerField.get_children():
		slot.clear_slot()

func reset_stats():
	player_stats.attack = 0
	player_stats.defense = 0
	enemy_stats.attack = 0
	enemy_stats.defense = 0


func get_wield_stat(stats):
	var result = null
	if stats.state == State.ATTACK:
		result = stats.attack
	if stats.state == State.DEFENSE:
		result = stats.defense
	if stats.state == State.NEUTRAL:
		result = null
	return result
func setup_button(card):
	var card_button = Button.new()
	card_button.connect("pressed",self,"player_card_picked",[card])
	card_button.add_stylebox_override("normal",StyleBoxEmpty.new())
	card_button.add_stylebox_override("pressed",StyleBoxEmpty.new())
	card_button.add_stylebox_override("hover",StyleBoxEmpty.new())
	card.add_child(card_button)

func player_card_picked(card):
	if !player_turn:
		return
	var empty_slot = get_empty_slot(PlayerField)
	var move_pos = empty_slot.get_global_rect().position
	card.animate_playcard(move_pos)
	yield(Co.wait(.3),"completed")

	empty_slot.set_card(card)
	if active_field(Team.PLAYER):
		player_stats = evaluate_state(Team.PLAYER)
		set_state(player_stats.state,Team.PLAYER)
	set_player_turn(false)
	emit_signal("enemyturn")


func set_state(state,team):
	var label = PlayerState if team == Team.PLAYER else EnemyState
	if state == State.NEUTRAL:
		label.text = "Neutral"
	if state == State.ATTACK:
		label.text = "Attacking"
	if state == State.DEFENSE:
		label.text = "Defending"

func get_empty_slot(container):
	var result = null
	for slot in container.get_children():
		if !slot.occupied():
			result = slot
			break
	return result

func draw_card(team):
	var hand = PlayerHandGrid if team == Team.PLAYER else OpponentHandGrid
	var deck:Array = player_deck if team == Team.PLAYER else enemy_deck
	var card = deck.pop_front()
	var hand_slot = null
	var draw_point = PlayerDeck if team == Team.PLAYER else EnemyDeck
	if card == null:
		return
	hand_slot = get_empty_slot(hand)
	if hand_slot == null:
		return

	if team == Team.PLAYER:
		setup_button(card)
	set_card_colors(card, team)
	draw_point.set_card(card)
	card.rect_position = Vector2.ZERO
	card.animate_playcard(hand_slot.rect_global_position,.3)
	yield(Co.wait(0.3),"completed")
	hand_slot.set_card(card)

func enemy_move():
	var co = GlobalMessageDialog.passive_message.show_message("Enemy Turn")
	yield (Co.safe_yield(self, co), "completed")
	if can_draw_card(Team.ENEMY):
		yield(Co.wrap(draw_card(Team.ENEMY)),"completed")
		yield(Co.wait(1),"completed")
	var card

	if enemy_stats.state == State.NEUTRAL:
		card = get_random()
	if enemy_stats.state == State.ATTACK:
		card = get_card(State.ATTACK)
	if enemy_stats.state == State.DEFENSE:
		card = get_card(State.DEFENSE)

	var empty_slot = get_empty_slot(EnemyField)
	var move_pos = empty_slot.get_global_rect().position
	card.animate_playcard(move_pos)
	yield(Co.wait(.5),"completed")

	empty_slot.set_card(card)

	if active_field(Team.ENEMY):
		enemy_stats = evaluate_state(Team.ENEMY)
		set_state(enemy_stats.state,Team.ENEMY)
	set_player_turn(true)
	co = GlobalMessageDialog.passive_message.show_message("Your Turn")
	yield (Co.safe_yield(self, co), "completed")

func active_field(team:int)->bool:
	var result:bool = false
	var field = PlayerField if team == Team.PLAYER else EnemyField
	for slot in field.get_children():
		if slot.occupied():
			result = true
			break
	return result

func evaluate_state(team:int):
	var teamfield = PlayerField if team == Team.PLAYER else EnemyField
	var stats = player_stats if team == Team.PLAYER else enemy_stats
	for slot in teamfield.get_children():
		if !slot.occupied():
			continue
		stats.attack += slot.card_info.attack
		stats.defense += slot.card_info.defense
	if stats.attack > stats.defense:
		stats.state = State.ATTACK
	if stats.defense > stats.attack:
		stats.state = State.DEFENSE
	if stats.defense == stats.attack:
		stats.state = State.NEUTRAL
	return stats

func get_card(state):
	var choice
	if state == State.ATTACK:
		for slot in OpponentHandGrid.get_children():
			if !slot.occupied():
				continue
			if choice == null:
				choice = slot.get_card()
				continue
			if choice.card_info.attack < slot.card_info.attack:
				choice = slot.get_card()
	if state == State.DEFENSE:
		for slot in OpponentHandGrid.get_children():
			if !slot.occupied():
				continue
			if choice == null:
				choice = slot.get_card()
				continue
			if choice.card_info.defense < slot.card_info.defense:
				choice = slot.get_card()
	return choice

func get_random():
	var choice = null
	var options = []
	for slot in OpponentHandGrid.get_children():
		if slot.occupied():
			options.push_back(slot.get_card())
	choice = random.choice(options)
	return choice

func set_player_turn(value:bool):
	if ready_to_resolve():
		resolve_field()
	if value:
		if can_draw_card(Team.PLAYER):
			yield(Co.wrap(draw_card(Team.PLAYER)),"completed")
			yield(Co.wait(0.3),"completed")
	player_turn = value

func can_draw_card(team):
	var grid = PlayerHandGrid if team == Team.PLAYER else OpponentHandGrid
	for slot in grid.get_children():
		if !slot.occupied():
			return true

func build_demo_deck(team:int)->Array:
	var deck:Array = []
	for _i in range (0,15):
		var form = random.choice(MonsterForms.basic_forms.values())
		var card = card_template.instance()
		card.form = form
		deck.push_back(card.duplicate())
	deck.shuffle()
	return deck

