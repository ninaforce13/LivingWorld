extends "res://menus/BaseMenu.gd"
signal enemyturn
signal gameover
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
onready var EnemySprite = find_node("EnemySprite")
onready var PlayerSprite = find_node("PlayerSprite")
onready var PlayerHeartGauge = find_node("PlayerHeartGauge")
onready var EnemyHeartGauge = find_node("EnemyHeartGauge")

export (Dictionary) var player_setup
export (Dictionary) var enemy_setup
export (int) var deck_seed
export (Dictionary) var player_data
export (Dictionary) var enemy_data


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
var winner_name:String
var enemy_tween:Tween
var player_tween:Tween


func _ready():
	PlayerSprite.animate_turn_end()
	EnemySprite.animate_turn_end()
	set_heartgauge_tween()
	if player_data:
		PlayerSprite.set_sprite(player_data)
	if enemy_data:
		EnemySprite.set_sprite(enemy_data)
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
	connect("gameover",self,"end_game")
	if PlayerHandGrid.get_child_count() < 5:
		yield(Co.wait(5),"completed")
	set_focus_buttons()
	set_player_turn(true)

func set_heartgauge_tween():
	if !PlayerHeartGauge.has_node("Tween"):
		player_tween = Tween.new()
		PlayerHeartGauge.add_child(player_tween)
	if !EnemyHeartGauge.has_node("Tween"):
		enemy_tween = Tween.new()
		EnemyHeartGauge.add_child(enemy_tween)

func end_game():
	var winner = get_winner_name()
	var player_wins:bool = winner == WorldSystem.get_player().name
	player_turn = false
	if player_wins:
		EnemySprite.animate_defeat()
	else:
		PlayerSprite.animate_defeat()
	var co = GlobalMessageDialog.passive_message.show_message("This Game's Winner is: %s"%winner)
	yield (Co.safe_yield(self, co), "completed")
	choose_option(winner == WorldSystem.get_player().name)

func is_game_ended()->bool:
	return player_stats.hp == 0 or enemy_stats.hp == 0

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
	print("player value: %s vs enemy value: %s"%[str(chosen_player_stat),str(chosen_enemy_stat)])
	if chosen_player_stat > chosen_enemy_stat:
		EnemySprite.animate_damage()
		animate_heart_damage(Team.ENEMY)
		enemy_stats.hp -= 1
		EnemyHealth.text = str(enemy_stats.hp)
		GlobalMessageDialog.passive_message.show_message("Round Winner: Player")

	if chosen_player_stat < chosen_enemy_stat:
		PlayerSprite.animate_damage()
		animate_heart_damage(Team.PLAYER)
		player_stats.hp -= 1
		PlayerHealth.text = str(player_stats.hp)
		GlobalMessageDialog.passive_message.show_message("Round Winner: Enemy")

	if chosen_player_stat == chosen_enemy_stat:
		GlobalMessageDialog.passive_message.show_message("Draw")
	reset_stats()
	yield(Co.wait(2),"completed")
	clear_battlefield()
	set_state(enemy_stats.state,Team.ENEMY)
	set_state(player_stats.state,Team.PLAYER)
	yield(Co.wait(3),"completed")

func clear_battlefield():
	for slot in EnemyField.get_children():
		var movepos = EnemyDeck.rect_global_position
		yield(Co.wrap(slot.clear_slot(true,movepos)),"completed")
	for slot in PlayerField.get_children():
		var movepos = PlayerDeck.rect_global_position
		yield(Co.wrap(slot.clear_slot(true,movepos)),"completed")

func reset_stats():
	player_stats.attack = 0
	player_stats.defense = 0
	enemy_stats.attack = 0
	enemy_stats.defense = 0
	player_stats.state = State.NEUTRAL
	enemy_stats.state = State.NEUTRAL

func get_wield_stat(stats):
	var result = null
	if stats.state == State.ATTACK:
		result = stats.attack
	if stats.state == State.DEFENSE:
		result = stats.defense
	if stats.state == State.NEUTRAL:
		result = stats.attack
	return result

func setup_button(card):
	var card_button = Button.new()
	var child_index = card.get_parent().get_index()
	card_button.name = "Button"
	card_button.focus_mode = Control.FOCUS_ALL
	card_button.connect("pressed",self,"player_card_picked",[card])
	card_button.connect("mouse_entered",card_button,"grab_focus")
	card_button.connect("mouse_entered",card,"animate_hover_enter")
	card_button.connect("focus_entered",card,"animate_hover_enter")
	card_button.connect("focus_exited",card,"animate_hover_exit")
	card_button.connect("mouse_exited",card,"animate_hover_exit")
	card_button.add_stylebox_override("normal",StyleBoxEmpty.new())
	card_button.add_stylebox_override("pressed",StyleBoxEmpty.new())
	card_button.add_stylebox_override("hover",StyleBoxEmpty.new())
	card_button.add_stylebox_override("focus",StyleBoxEmpty.new())
	card.add_child(card_button)

func set_focus_buttons():
	var focus_index:int = 5
	var focus_button = null
	for slot in PlayerHandGrid.get_children():
		if slot.occupied():
			var next_index = get_next_occupied_slot(slot)
			var prev_index = get_previous_occupied_slot(slot)
			var right_neighbor = PlayerHandGrid.get_child(next_index).get_card() if next_index > -1 else null
			var left_neighbor = PlayerHandGrid.get_child(prev_index).get_card() if prev_index > -1 else null
			var cardbutton = slot.get_card().get_node("Button")

			if left_neighbor:
				cardbutton.focus_neighbour_left = left_neighbor.get_node("Button").get_path()
			if right_neighbor:
				cardbutton.focus_neighbour_right = right_neighbor.get_node("Button").get_path()
			if slot.get_index() < focus_index:
				focus_index = slot.get_index()
				focus_button = cardbutton

	if focus_button:
		focus_button.grab_focus()

func get_previous_occupied_slot(current_slot):
	var prev_index = -1
	for i in range (current_slot.get_index()-1,-1,-1):
		if PlayerHandGrid.get_child(i).occupied():
			prev_index = i
			break
	if prev_index < 0:
		for i in range (4,current_slot.get_index(),-1):
			if PlayerHandGrid.get_child(i).occupied():
				prev_index = i
				break
	return prev_index

func get_next_occupied_slot(current_slot):
	var next_index = -1
	for i in range (current_slot.get_index()+1,5):
		if PlayerHandGrid.get_child(i).occupied():
			next_index = i
			break
	if next_index < 0:
		for i in range (0,current_slot.get_index()):
			if PlayerHandGrid.get_child(i).occupied():
				next_index = i
				break
	return next_index

func player_card_picked(card):
	if !player_turn:
		return
	var empty_slot = get_empty_slot(PlayerField)
	var move_pos = empty_slot.get_global_rect().position
	card.animate_playcard(move_pos)
	yield(Co.wait(.3),"completed")
	if card.has_node("Button"):
		var button = card.get_node("Button")
		card.remove_child(button)
	empty_slot.set_card(card)
	if active_field(Team.PLAYER):
		player_stats = evaluate_state(Team.PLAYER, card)
		set_state(player_stats.state,Team.PLAYER)
	set_focus_buttons()
	set_player_turn(false)
	emit_signal("enemyturn")
	PlayerSprite.animate_turn_end()

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

	set_card_colors(card, team)
	draw_point.set_card(card)
	card.rect_position = Vector2.ZERO
	card.animate_playcard(hand_slot.rect_global_position,.3)
	yield(Co.wait(0.3),"completed")
	hand_slot.set_card(card)
	if team == Team.PLAYER:
		setup_button(card)

func enemy_move():
	EnemySprite.animate_turn()
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
		enemy_stats = evaluate_state(Team.ENEMY,card)
		set_state(enemy_stats.state,Team.ENEMY)
	EnemySprite.animate_turn_end()
	set_player_turn(true)

func active_field(team:int)->bool:
	var result:bool = false
	var field = PlayerField if team == Team.PLAYER else EnemyField
	for slot in field.get_children():
		if slot.occupied():
			result = true
			break
	return result

func evaluate_state(team:int, card):
	var stats = player_stats if team == Team.PLAYER else enemy_stats
	stats.attack += card.card_info.attack
	stats.defense += card.card_info.defense
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
		yield(Co.wrap(resolve_field()),"completed")
		yield(Co.wait(0.5),"completed")
		if is_game_ended():
			emit_signal("gameover")
			return

	if value:
		GlobalMessageDialog.passive_message.show_message("Your Turn")
		PlayerSprite.animate_turn()
		if can_draw_card(Team.PLAYER):
			yield(Co.wrap(draw_card(Team.PLAYER)),"completed")
			yield(Co.wait(0.3),"completed")
			set_focus_buttons()
	player_turn = value

func get_winner_name()->String:
	var result:String =  ""
	if player_stats.hp > 0:
		result = WorldSystem.get_player().name
	else:
		result = "Ranger"
	return result

func can_draw_card(team)->bool:
	var grid = PlayerHandGrid if team == Team.PLAYER else OpponentHandGrid
	for slot in grid.get_children():
		if !slot.occupied():
			return true
	return false

func build_demo_deck(_team:int)->Array:
	var deck:Array = []
	for _i in range (0,25):
		var form = random.choice(MonsterForms.basic_forms.values())
		var card = card_template.instance()
		card.form = form
		deck.push_back(card.duplicate())
	deck.shuffle()
	return deck

func animate_heart_damage(team):
	var duration = 0.3
	if team == Team.PLAYER:
		var origin = PlayerHeartGauge.rect_position
		player_tween.interpolate_property(PlayerHeartGauge,"rect_position",origin,origin + Vector2(50,0),duration,Tween.TRANS_BOUNCE,Tween.EASE_IN)
		player_tween.start()
		yield(player_tween,"tween_completed")
		player_tween.interpolate_property(PlayerHeartGauge,"rect_position",origin + Vector2(50,0),origin,duration,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
		player_tween.start()
		yield(player_tween,"tween_completed")
	if team == Team.ENEMY:
		var origin = EnemyHeartGauge.rect_position
		enemy_tween.interpolate_property(EnemyHeartGauge,"rect_position",origin,origin + Vector2(50,0),duration,Tween.TRANS_BOUNCE,Tween.EASE_IN)
		enemy_tween.start()
		yield(enemy_tween,"tween_completed")
		enemy_tween.interpolate_property(EnemyHeartGauge,"rect_position",origin + Vector2(50,0),origin,duration,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
		enemy_tween.start()
		yield(enemy_tween,"tween_completed")
