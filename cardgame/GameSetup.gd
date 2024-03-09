extends "res://menus/BaseMenu.gd"
signal enemyturn
signal gameover
signal field_cleared
signal hand_drawn
signal card_drawn
signal thinking_complete
signal labels_updated
enum DamageType {NEUTRAL, DAMAGE, HEAL}

const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
const manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
const damage_pop = preload("res://mods/LivingWorld/cardgame/damage_pop.tscn")
const settings = preload("res://mods/LivingWorld/settings.tres")
const resolve_value:int = 3

onready var EnemyHandGrid = find_node("OpponentHandGrid")
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
onready var PlayerName = find_node("PlayerName")
onready var EnemyName = find_node("EnemyName")
onready var PlayerHeartGauge = find_node("PlayerHeartGauge")
onready var EnemyHeartGauge = find_node("EnemyHeartGauge")
onready var EnemyAttackLabel = find_node("EnemyAttackValue")
onready var EnemyDefenseLabel = find_node("EnemyDefenseValue")
onready var PlayerAttackLabel = find_node("AttackValue")
onready var PlayerDefenseLabel = find_node("DefenseValue")
onready var Banner = find_node("Banner")
onready var BannerStart = find_node("BannerStart")
onready var BannerEnd = find_node("BannerEnd")
onready var PlayerDamageStart1 = find_node("PlayerDamageStart1")
onready var PlayerDamageStart2 = find_node("PlayerDamageStart2")
onready var PlayerDamageStart3 = find_node("PlayerDamageStart3")
onready var EnemyDamageStart1 = find_node("EnemyDamageStart1")
onready var EnemyDamageStart2 = find_node("EnemyDamageStart2")
onready var EnemyDamageStart3 = find_node("EnemyDamageStart3")
onready var GameSFX = find_node("game_sfx_player")
onready var PlayerPointMeter = find_node("PointMeter")
onready var EnemyPointMeter = find_node("EnemyPointMeter")
onready var PlayerSlot1 = find_node("PlayerSlot1")
onready var PlayerSlot2 = find_node("PlayerSlot2")
onready var PlayerSlot3 = find_node("PlayerSlot3")
onready var PlayerSlot4 = find_node("PlayerSlot4")
onready var PlayerSlot5 = find_node("PlayerSlot5")
onready var EnemySlot1 = find_node("EnemySlot1")
onready var EnemySlot2 = find_node("EnemySlot2")
onready var EnemySlot3 = find_node("EnemySlot3")
onready var EnemySlot4 = find_node("EnemySlot4")
onready var EnemySlot5 = find_node("EnemySlot5")
onready var PlayerDeckPos = find_node("PlayerDeckPos")
onready var EnemyDeckPos = find_node("EnemyDeckPos")

export (Dictionary) var player_setup
export (Dictionary) var enemy_setup
export (int) var game_seed
export (Color) var attack_color
export (Color) var defend_color
export (Color) var neutral_color
export (Color) var remaster_bonus_color
export (Dictionary) var player_data
export (Dictionary) var enemy_data
export (bool) var demo = false
export (bool) var logs = false
enum State {ATTACK,DEFENSE,NEUTRAL}
enum Team  {PLAYER,ENEMY}
var random:Random
var player_deck:Array = []
var player_discard:Array = []
var enemy_deck:Array = []
var enemy_discard:Array = []
var player_turn:bool = false
var player_entry_point
var enemy_entry_point
var player_stats:Dictionary = {
								"max_hp":6,
								"hp":6,
								"state":State.NEUTRAL,
								"attack":0,
								"defense":0,
								"attack_display":0,
								"defense_display":0,
								"remaster_bonus":0,
								"full_remaster_bonus":0}
var enemy_stats:Dictionary = player_stats.duplicate()
var winner_name:String
var enemy_tween:Tween
var player_tween:Tween
var player_damage_start:Array = []
var enemy_damage_start:Array = []
var tween:Tween
var player_state:int = State.NEUTRAL
var enemy_state:int = State.NEUTRAL
var state_changed:bool = false

func _ready():
	random = Random.new()
	tween = Tween.new()
	add_child(tween)
	PlayerSprite.animate_turn_end()
	EnemySprite.animate_turn_end()

	set_heartgauge_tween()
	set_sprites()
	initialize_decks()
	populate_damage_pop_arrays()
	connect("enemyturn",self,"enemy_move")
	connect("gameover",self,"end_game")

	draw_initial_hand()
	yield(self,"hand_drawn")

	set_focus_buttons()

	console_log("Match Start")
	if coin_toss():
		console_log("Player wins coin toss.")
		set_player_turn(true)
	else:
		console_log("Enemy wins coin toss.")
		enemy_move()

func coin_toss()->bool:
	if demo:
		return false
	return random.rand_bool()

func populate_damage_pop_arrays():
	player_damage_start.push_back(PlayerDamageStart1)
	player_damage_start.push_back(PlayerDamageStart2)
	player_damage_start.push_back(PlayerDamageStart3)

	enemy_damage_start.push_back(EnemyDamageStart1)
	enemy_damage_start.push_back(EnemyDamageStart2)
	enemy_damage_start.push_back(EnemyDamageStart3)

func get_random_start_point(team):
	if team == Team.PLAYER:
		return random.choice(player_damage_start)
	else:
		return random.choice(enemy_damage_start)

func set_sprites():
	if demo:
		return
	if player_data:
		PlayerSprite.set_sprite(player_data)
		PlayerName.text = player_data.name
	if enemy_data:
		EnemySprite.set_sprite(enemy_data)
		EnemyName.text = Loc.tr(enemy_data.name)

func initialize_decks():
	if player_deck.empty():
		if demo:
			player_deck = build_demo_deck(0)
		else:
			player_deck = get_player_deck()
		random.shuffle(player_deck)
	if enemy_deck.empty():
		enemy_deck = build_demo_deck(1)
		random.shuffle(enemy_deck)

func draw_initial_hand():
	for _i in range (0,5):
		draw_card(Team.PLAYER)
		yield(self,"card_drawn")
	for _i in range (0,5):
		draw_card(Team.ENEMY)
		yield(self,"card_drawn")
	emit_signal("hand_drawn")

func set_heartgauge_tween():
	if !PlayerHeartGauge.has_node("Tween"):
		player_tween = Tween.new()
		PlayerHeartGauge.add_child(player_tween)
	if !EnemyHeartGauge.has_node("Tween"):
		enemy_tween = Tween.new()
		EnemyHeartGauge.add_child(enemy_tween)

func end_game():
	var winner = get_winner_name()
	console_log("%s wins match."%winner)
	refresh_deck(player_deck,player_discard)
	refresh_deck(enemy_deck,enemy_discard)
	var player_wins:bool
	if !demo:
		player_wins = winner == SaveState.party.player.name
	else:
		player_wins = winner == "Nate"
	player_turn = false
	if player_wins:
		EnemySprite.animate_defeat()
	else:
		PlayerSprite.animate_defeat()
	var team = Team.PLAYER if player_wins else Team.ENEMY
	var text = "%s Wins!"%Loc.tr(winner)
	PlayBanner(team,text,"remaster")
	yield(Banner.tween,"tween_completed")
	choose_option(player_wins)

func is_game_ended()->bool:
	return player_stats.hp == 0 or enemy_stats.hp == 0

func set_card_colors(card,team): #Obsolete
	var setup = player_setup if team == Team.PLAYER else enemy_setup
	card.bordercolor = setup.bordercolor
	card.bandcolor = setup.bandcolor
	card.backcolor = setup.backcolor

func ready_to_resolve()->bool:
	var result:bool = true
	for slot in EnemyField.get_children():
		if !slot.occupied():
			result = false
			break
	for slot in PlayerField.get_children():
		if !slot.occupied():
			result = false
	if logs and result:
		console_log("Ready to resolve field")
	return result

func resolve_stats(stats:Dictionary)->Dictionary:
	var result:Dictionary = {"attack":0,"defense":0}
	result.attack = int(stats.attack / resolve_value) if stats.state != State.DEFENSE else 0
	result.defense = int(stats.defense / resolve_value) if stats.state != State.ATTACK else 0
	result.attack += stats.remaster_bonus
	result.defense += stats.remaster_bonus
	result.attack += stats.full_remaster_bonus
	result.defense += stats.full_remaster_bonus
	return result

func reset_labels():
	PlayerDefenseLabel.text = "0"
	PlayerAttackLabel.text = "0"
	EnemyAttackLabel.text = "0"
	EnemyDefenseLabel.text = "0"
	EnemyAttackLabel.remove_color_override("font_color")
	EnemyDefenseLabel.remove_color_override("font_color")
	PlayerAttackLabel.remove_color_override("font_color")
	PlayerDefenseLabel.remove_color_override("font_color")

func update_value_labels(team):
	var stats = player_stats if team == Team.PLAYER else enemy_stats
	var defense_label = PlayerDefenseLabel if team == Team.PLAYER else EnemyDefenseLabel
	var attack_label = PlayerAttackLabel if team == Team.PLAYER else EnemyAttackLabel
	var point_meter = PlayerPointMeter if team == Team.PLAYER else EnemyPointMeter
	var debug_name:String = "Player" if team == Team.PLAYER else "Enemy"
	var result = resolve_stats(stats)
	var current_value:int = 0
	if stats.state == State.ATTACK or stats.state == State.NEUTRAL:

		defense_label.text = str(result.defense)
		stats.defense_display = result.defense
		current_value = stats.attack_display
		var difference = result.attack - current_value
		if difference > 0:
			for _i in range (difference):
				point_meter.fill_remainder()
				yield(point_meter,"fill_complete")
				current_value += 1
				attack_label.text = str(current_value)
				stats.attack_display = current_value
				if stats.state == State.NEUTRAL:
					defense_label.text = str(current_value)
					stats.defense_display = current_value
				point_meter.reset_bar()

		var remainder = ((stats.attack + (stats.remaster_bonus * resolve_value) + (stats.full_remaster_bonus * resolve_value))%3) - point_meter.filled_count
		if point_meter.filled_count != remainder:
			point_meter.fill_bar(remainder)
			yield(point_meter,"fill_complete")

	if stats.state == State.DEFENSE:
		attack_label.text = str(result.attack)
		stats.attack_display = result.attack
		current_value = stats.defense_display
		var difference = result.defense - current_value
		for _i in range (difference):
			point_meter.fill_remainder()
			yield(point_meter,"fill_complete")
			current_value += 1
			defense_label.text = str(current_value)
			stats.defense_display = current_value
			point_meter.reset_bar()

		var remainder = ((stats.defense + (stats.remaster_bonus * resolve_value)+ (stats.full_remaster_bonus * resolve_value))%3) - point_meter.filled_count
		if point_meter.filled_count != remainder:
			point_meter.fill_bar(remainder)
			yield(point_meter,"fill_complete")

	if stats.remaster_bonus > 0 or stats.full_remaster_bonus > 0 :
		attack_label.add_color_override("font_color",remaster_bonus_color)
		defense_label.add_color_override("font_color",remaster_bonus_color)
	else:
		attack_label.remove_color_override("font_color")
		defense_label.remove_color_override("font_color")

	if demo:
		console_log("""
	%s Breakdown:
	Full Stats %s
	Normalized Stats %s"""%[debug_name,str(stats),str(result)])

	call_deferred("emit_signal","labels_updated")

func resolve_field():
	var player_result:Dictionary = resolve_stats(player_stats)
	var enemy_result:Dictionary = resolve_stats(enemy_stats)
	var damage
	if player_result.attack > enemy_result.defense:
		EnemySprite.animate_damage()
		damage = player_result.attack - enemy_result.defense
		var text = "- %s"%str(damage)
		animate_heart_damage(Team.ENEMY)
		animate_damage_pop(Team.ENEMY,text,DamageType.DAMAGE)
		enemy_stats.hp -= damage
		enemy_stats.hp = clamp(enemy_stats.hp,0,enemy_stats.max_hp)
		EnemyHealth.text = str(enemy_stats.hp)

		console_log("Player attacks Enemy. Dealing %s damage"%damage)
		GameSFX.play_track("damage")

	if player_result.defense > enemy_result.attack and player_stats.hp < player_stats.max_hp:
		damage = player_result.defense - enemy_result.attack
		var text = "+ %s"%str(damage)
		animate_damage_pop(Team.PLAYER,text,DamageType.HEAL)
		player_stats.hp += damage
		player_stats.hp = clamp(player_stats.hp, 0, player_stats.max_hp)
		PlayerHealth.text = str(player_stats.hp)

		console_log("Player blocks Enemy attack. Heals for %s remaining defense value."%damage)
		GameSFX.play_track("heal")
	elif player_result.defense > enemy_result.attack and player_stats.hp >= player_stats.max_hp and enemy_result.attack > 0:

		console_log("Player blocks Enemy attack.")
		animate_damage_pop(Team.PLAYER,"Blocked!",DamageType.NEUTRAL)
		GameSFX.play_track("blocked")


	if enemy_result.attack > player_result.defense:
		damage = enemy_result.attack - player_result.defense
		var text = "- %s"%str(damage)
		PlayerSprite.animate_damage()
		animate_heart_damage(Team.PLAYER)
		animate_damage_pop(Team.PLAYER,text,DamageType.DAMAGE)
		player_stats.hp -= damage
		player_stats.hp = clamp(player_stats.hp,0,player_stats.max_hp)
		PlayerHealth.text = str(player_stats.hp)
		console_log("Enemy attacks Player. Dealing %s damage"%damage)
		GameSFX.play_track("damage")

	if enemy_result.defense > player_result.attack and enemy_stats.hp < enemy_stats.max_hp:
		damage = enemy_result.defense - player_result.attack
		var text = "+ %s"%str(damage)
		animate_damage_pop(Team.ENEMY,text,DamageType.HEAL)
		enemy_stats.hp += damage
		enemy_stats.hp = clamp(enemy_stats.hp,0,enemy_stats.max_hp)
		EnemyHealth.text = str(enemy_stats.hp)
		console_log("Enemy blocks Player attack. Heals for %s remaining defense value."%damage)
		GameSFX.play_track("heal")
	elif enemy_result.defense > player_result.attack and enemy_stats.hp >= enemy_stats.max_hp and player_result.attack > 0:
		console_log("Enemy blocks Player attack.")
		animate_damage_pop(Team.ENEMY,"Blocked!",DamageType.NEUTRAL)
		GameSFX.play_track("blocked")

	if enemy_result.defense == player_result.attack and player_result.attack != 0:
		console_log("Enemy blocks Player attack.")
		animate_damage_pop(Team.ENEMY,"Blocked!",DamageType.NEUTRAL)
		GameSFX.play_track("blocked")
	if player_result.defense == enemy_result.attack and enemy_result.attack != 0:
		console_log("Player blocks Enemy attack.")
		animate_damage_pop(Team.PLAYER,"Blocked!",DamageType.NEUTRAL)
		GameSFX.play_track("blocked")

	reset_stats()
	yield(Co.wait(2),"completed")
	clear_battlefield()
	yield(self,"field_cleared")
	PlayerPointMeter.reset_bar()
	EnemyPointMeter.reset_bar()
	reset_labels()
	set_state(enemy_stats.state,Team.ENEMY)
	set_state(player_stats.state,Team.PLAYER)
	var co_list:Array = []
	co_list.push_back(animate_hover_enter(EnemyState))
	co_list.push_back(animate_hover_enter(PlayerState))
	yield(Co.join(co_list),"completed")
	co_list.clear()

	co_list.push_back(animate_hover_exit(EnemyState))
	co_list.push_back(animate_hover_exit(PlayerState))
	yield(Co.join(co_list),"completed")

	enemy_state = enemy_stats.state
	player_state = player_stats.state

func animate_damage_pop(team,value,damage_type = 0 ):
	var start = get_random_start_point(team).global_position
	var damage = damage_pop.instance()
	damage.type = damage_type
	damage.text = value
	add_child(damage)
	damage.rect_global_position = start
	damage.animate_pop()

func clear_battlefield():
	var co_list:Array = []
	for slot in EnemyField.get_children():
		co_list.push_back(slot.get_card().flip_card(0.1))
	for slot in PlayerField.get_children():
		co_list.push_back(slot.get_card().flip_card(0.1))
	yield(Co.join(co_list),"completed")
	yield(Co.wait(0.5),"completed")

	for slot in EnemyField.get_children():
		var movepos = EnemyDeckPos.position
		enemy_discard.push_back(slot.get_card().duplicate())
		slot.get_card().discard_card(movepos,0.1)
		yield(slot.get_card().tween,"tween_all_completed")
		slot.clear_slot()

	for slot in PlayerField.get_children():
		var movepos = PlayerDeckPos.position
		player_discard.push_back(slot.get_card().duplicate())
		slot.get_card().discard_card(movepos,0.1)
		yield(slot.get_card(),"card_discarded")
		slot.clear_slot()

	emit_signal("field_cleared")

func reset_stats():
	player_stats.attack = 0
	player_stats.defense = 0
	player_stats.attack_display = 0
	player_stats.defense_display = 0
	player_stats.remaster_bonus = 0
	player_stats.full_remaster_bonus = 0
	enemy_stats.attack = 0
	enemy_stats.attack_display = 0
	enemy_stats.defense_display = 0
	enemy_stats.defense = 0
	enemy_stats.remaster_bonus = 0
	enemy_stats.full_remaster_bonus = 0

	player_stats.state = State.NEUTRAL
	enemy_stats.state = State.NEUTRAL

func setup_button(card):
	var card_button = Button.new()
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
	card_button.rect_size = card.rect_size

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
	var empty_slot_data:Dictionary = get_empty_slot(PlayerField)
	var empty_slot = empty_slot_data.slot
	var move_pos = empty_slot.get_global_rect().position
	console_log("Player chose %s"%card.card_name.text)
	card.animate_playcard(move_pos,0.2)
	var remaster_bonus:bool = is_remaster(PlayerField,card) if player_stats.remaster_bonus == 0 else false
	var full_remaster_bonus:bool = is_full_remaster(PlayerField,card) if player_stats.full_remaster_bonus == 0 else false
	if full_remaster_bonus or player_stats.full_remaster_bonus > 0:
		remaster_bonus = false
	yield(card.tween,"tween_completed")

	if card.has_node("Button"):
		var button = card.get_node("Button")
		card.remove_child(button)
	empty_slot.set_card(card)
	if remaster_bonus or full_remaster_bonus:
		console_log("Player Remaster triggered")
		if remaster_bonus:
			player_stats.remaster_bonus += 1
		if full_remaster_bonus:
			player_stats.full_remaster_bonus += 2
		var banner_text = "LIVINGWORLD_CARDS_UI_REMASTER_BONUS" if remaster_bonus else "LIVINGWORLD_CARDS_UI_FULL_REMASTER_BONUS"
		PlayBanner(Team.PLAYER, banner_text, "remaster")
		yield(Banner.tween,"tween_completed")
	if active_field(Team.PLAYER):
		player_stats = evaluate_state(Team.PLAYER, card, remaster_bonus)
		set_state(player_stats.state,Team.PLAYER)
		if state_changed:
			animate_hover_enter(PlayerState)
			animate_hover_exit(PlayerState)
			yield(tween,"tween_completed")
			state_changed = false
			player_state = player_stats.state
		update_value_labels(Team.PLAYER)
		yield(self,"labels_updated")
	set_focus_buttons()
	set_player_turn(false)

func PlayBanner(team, text, track):
	Banner.set_colors(team)
	Banner.set_text(text)
	var co_list:Array = []
	co_list.push_back(GameSFX.play_track(track))
	co_list.push_back(Banner.animate_banner(BannerStart.global_position,BannerEnd.global_position,1.5))
	yield(Co.join(co_list),"completed")

func set_state(state,team):
	var label:Label = PlayerState if team == Team.PLAYER else EnemyState
	if state == State.NEUTRAL:
		label.text = "LIVINGWORLD_CARDS_UI_NEUTRAL"
		label.add_color_override("font_color",neutral_color)
	if state == State.ATTACK:
		label.text = "LIVINGWORLD_CARDS_UI_ATTACK"
		label.add_color_override("font_color",attack_color)
	if state == State.DEFENSE:
		label.text = "LIVINGWORLD_CARDS_UI_DEFENSE"
		label.add_color_override("font_color",defend_color)

func get_empty_slot(container)->Dictionary:
	var result = {"slot":null,"index":0}
	var index:int = 0
	for slot in container.get_children():
		if !slot.occupied():
			result.slot = slot
			result.index = index
			break
		index += 1
	return result

func draw_card(team):
	var hand = PlayerHandGrid if team == Team.PLAYER else EnemyHandGrid
	var deck:Array = player_deck if team == Team.PLAYER else enemy_deck
	var discard:Array = player_discard if team == Team.PLAYER else enemy_discard
	var card = deck.pop_front() if !deck.empty() else refresh_deck(deck,discard)
	var hand_slot = null
	var draw_point = PlayerDeck if team == Team.PLAYER else EnemyDeck
	var hand_position
	if card == null:
		return
	var hand_slot_data:Dictionary = {}
	hand_slot_data = get_empty_slot(hand)
	hand_slot = hand_slot_data.slot

	hand_position = get_slot_position(hand_slot_data.index, team)

	if hand_slot == null:
		return

	set_card_colors(card, team)
	draw_point.set_card(card)
	card.rect_position = Vector2.ZERO
	var pos = hand_position.position
	card.draw_card(pos,.2)
	yield(card,"card_drawn")
	hand_slot.set_card(card)
	if team == Team.PLAYER or demo:
		if team == Team.PLAYER:
			setup_button(card)
		card.flip_card(0.1)
	emit_signal("card_drawn")

func get_slot_position(index:int,team):
	var hand_position
	if index == 0:
		hand_position = PlayerSlot1 if team == Team.PLAYER else EnemySlot1
	if index == 1:
		hand_position = PlayerSlot2 if team == Team.PLAYER else EnemySlot2
	if index == 2:
		hand_position = PlayerSlot3 if team == Team.PLAYER else EnemySlot3
	if index == 3:
		hand_position = PlayerSlot4 if team == Team.PLAYER else EnemySlot4
	if index == 4:
		hand_position = PlayerSlot5 if team == Team.PLAYER else EnemySlot5
	return hand_position

func refresh_deck(deck,discard):
	var card
	for _i in range(discard.size()):
		deck.push_back(discard.pop_front())
		random.shuffle(deck)
	card = deck.pop_front()
	return card

func animate_thinking(chosen_card):
	var wait_times:Array = [0.5,0.7,1]
	var slots:Array = EnemyHandGrid.get_children()
	for i in range(random.rand_range_int(1,2)):
		random.shuffle(slots)
		var peek_slot = slots.pop_front()
		var card = peek_slot.get_card()
		card.animate_hover_enter()
		yield(Co.wait(random.choice(wait_times)),"completed")
		card.animate_hover_exit()
		yield(card.tween,"tween_all_completed")
	chosen_card.animate_hover_enter()
	yield(Co.wait(random.choice(wait_times)),"completed")
	chosen_card.animate_hover_exit()
	yield(chosen_card.tween,"tween_all_completed")
	emit_signal("thinking_complete")

func enemy_move():
	EnemySprite.animate_turn()
	var text = "%s's Turn"%Loc.tr(enemy_data.name)
	PlayBanner(Team.ENEMY,text,"turn_start")
	yield(Banner.tween,"tween_completed")
	if can_draw_card(Team.ENEMY):
		draw_card(Team.ENEMY)
		yield(self,"card_drawn")

	var card = evaluate_situation()
	console_log("Enemy chose to play %s"%card.card_name.text)
	if manager.get_setting("EnemyCardThought"):
		animate_thinking(card)
		yield(self,"thinking_complete")
	if !demo:
		yield(Co.wait(0.1),"completed")
		card.flip_card(0.1)
	yield(Co.wait(0.3),"completed")
	if !card.is_faceup():
		card.flip_card(0.1)
	var empty_slot_data = get_empty_slot(EnemyField)
	var empty_slot = empty_slot_data.slot
	var move_pos = empty_slot.get_global_rect().position
	var remaster_bonus:bool = is_remaster(EnemyField,card) if enemy_stats.remaster_bonus == 0 else false
	var full_remaster_bonus:bool = is_full_remaster(EnemyField,card) if enemy_stats.full_remaster_bonus == 0 else false
	if full_remaster_bonus or enemy_stats.full_remaster_bonus > 0:
		remaster_bonus = false
	card.animate_playcard(move_pos,0.2)
	yield(card.tween,"tween_completed")
	empty_slot.set_card(card)
	if remaster_bonus or full_remaster_bonus:
		if remaster_bonus:
			console_log("Enemy Remaster Bonus: +1/1")
			enemy_stats.remaster_bonus += 1
		if full_remaster_bonus:
			enemy_stats.full_remaster_bonus += 2
			console_log("Enemy Full Remaster Bonus: +2/2")
		var banner_text = "LIVINGWORLD_CARDS_UI_REMASTER_BONUS" if remaster_bonus else "LIVINGWORLD_CARDS_UI_FULL_REMASTER_BONUS"
		PlayBanner(Team.ENEMY,banner_text,"remaster")
		yield(Banner.tween,"tween_completed")
	if active_field(Team.ENEMY):
		enemy_stats = evaluate_state(Team.ENEMY,card,remaster_bonus)
		set_state(enemy_stats.state,Team.ENEMY)
		if state_changed:
			animate_hover_enter(EnemyState)
			animate_hover_exit(EnemyState)
			yield(tween,"tween_completed")
			state_changed = false
			enemy_state = enemy_stats.state
		update_value_labels(Team.ENEMY)
		yield(self,"labels_updated")
	yield(Co.wait(0.5),"completed")
	EnemySprite.animate_turn_end()
	set_player_turn(true)

func is_remaster(field, new_card)->bool:
	var result:bool = false
	for card_slot in field.get_children():
		if !card_slot.occupied():
			continue
		var card = card_slot.get_card()
		var form = load(card.form)
		var new_card_form = load(new_card.form)
		if form.evolutions.size() > 0:
			for evo in form.evolutions:
				if evo.evolved_form == new_card_form:
					result = true
					break

	return result

func is_full_remaster(field, new_card)->bool:
	var all_forms = MonsterForms.basic_forms.values()
	var debut_forms = MonsterForms.pre_evolution.values()
	var remaster_line:Array = []
	var result:bool = false
	var first_slot = field.get_child(0)
	var second_slot = field.get_child(1)
	var new_card_form = load(new_card.form)
	var current_form = new_card_form
	if new_card_form.evolutions.size() > 0:
		return false
	if !first_slot.occupied():
		return false
	var previous_form = find_previous_form(current_form)
	if !previous_form:
		console_log("No previous forms found.")
		return false
	console_log("Form %s found"%Loc.tr(previous_form.name))
	remaster_line.push_front(previous_form) if previous_form in debut_forms else remaster_line.push_back(previous_form)
	current_form = previous_form
	previous_form = find_previous_form(current_form)
	if previous_form:
		console_log("Form %s found"%Loc.tr(previous_form.name))
		remaster_line.push_front(previous_form) if previous_form in debut_forms else remaster_line.push_back(previous_form)
	var remaster_count = remaster_line.size()
	if remaster_count == 2:
		console_log("3 Form Remaster Line %s"%str(remaster_line))
		if first_slot.get_card().form != remaster_line[0].resource_path:
			console_log("First slot is not debut form %s"%remaster_line[0].name)
			return false
		remaster_line.remove(0)
		if !second_slot.occupied():
			return false
		if second_slot.get_card().form != remaster_line[0].resource_path:
			console_log("Second slot is not next form %s"%remaster_line[0].name)
			return false
	elif remaster_count == 1:
		if second_slot.occupied():
			if first_slot.get_card().form != remaster_line[0].resource_path and second_slot.get_card().form != remaster_line[0].resource_path:
				return false
		else:
			if first_slot.get_card().form != remaster_line[0].resource_path:
				return false

	return true

func find_previous_form(current_form):
	var all_forms = MonsterForms.basic_forms.values()
	var debut_forms = MonsterForms.pre_evolution.values()
	var result = null
	for form in all_forms:
		for evo in form.evolutions:
			if current_form == evo.evolved_form:
					result = form
					break
	return result

func active_field(team:int)->bool:
	var result:bool = false
	var field = PlayerField if team == Team.PLAYER else EnemyField
	for slot in field.get_children():
		if slot.occupied():
			result = true
			break
	return result

func evaluate_state(team:int, card, bonus:bool):
	var stats = player_stats if team == Team.PLAYER else enemy_stats
	var old_state = player_state if team == Team.PLAYER else enemy_state
	stats.attack += card.card_info.attack
	stats.defense += card.card_info.defense
	if stats.attack > stats.defense:
		stats.state = State.ATTACK

	if stats.defense > stats.attack:
		stats.state = State.DEFENSE

	if stats.defense == stats.attack:
		stats.state = State.NEUTRAL

	if old_state != stats.state:
		state_changed = true
	return stats

func get_card(state):
	var choice
	if state == State.ATTACK:
		for slot in EnemyHandGrid.get_children():
			if !slot.occupied():
				continue
			if choice == null:
				choice = slot.get_card()
				continue
			if choice.card_info.attack < slot.card_info.attack:
				choice = slot.get_card()
	if state == State.DEFENSE:
		for slot in EnemyHandGrid.get_children():
			if !slot.occupied():
				continue
			if choice == null:
				choice = slot.get_card()
				continue
			if choice.card_info.defense < slot.card_info.defense:
				choice = slot.get_card()
	return choice

func evaluate_situation():
	console_log("Bot Evaluation...")
	var in_danger:bool = enemy_stats.hp < enemy_stats.max_hp / 3
	if in_danger:
		console_log("Bot is in danger.")
	else:
		console_log("Bot is safe.")
	var defensive:bool = random.rand_bool(0.8) if in_danger else random.rand_bool(0.3)
	var offensive:bool = random.rand_bool(0.8) if !defensive else false
	var remaster_card = is_remaster_possible()
	if remaster_card and !ai_misplay():
		console_log("Bot is planning to Remaster.")
		return remaster_card
	if defensive:
		console_log("Bot is playing defensively.")
		return get_card(State.DEFENSE)
	if offensive:
		console_log("Bot is playing offensively.")
		return get_card(State.ATTACK)
	console_log("Bot said screw it and decided to play randomly.")
	return get_random()

func console_log(text:String):
	if logs:
		print(text)

func ai_misplay()->bool:
	var result:bool = random.rand_bool(settings.cards_ai_misplay_rate)
	if result:
		console_log("Bot is loafing off.")
	return result

func is_remaster_possible():
	console_log("Bot is searching hand for a Remaster to use on the current field...")
	for card_slot in EnemyHandGrid.get_children():
		if is_remaster(EnemyField,card_slot.get_card()):
			return card_slot.get_card()
	console_log("Bot is searching hand for a Remaster combos to play later...")
	for card_slot in EnemyHandGrid.get_children():
		if is_remaster(EnemyHandGrid,card_slot.get_card()):
			console_log("Bot found %s can be used to Remaster later."%card_slot.get_card().card_info.name)
			return get_pre_remaster(EnemyHandGrid,card_slot.get_card())
	return null

func get_pre_remaster(field, new_card):
	for card_slot in field.get_children():
		if !card_slot.occupied():
			continue
		var card = card_slot.get_card()
		var form = load(card.form)
		var new_card_form = load(new_card.form)
		if form.evolutions.size() > 0:
			for evo in form.evolutions:
				if evo.evolved_form == new_card_form:
					console_log("Bot will use %s to setup a future Remaster."%card.card_info.name)
					return card

	return null

func get_random():
	var choice = null
	var options = []
	for slot in EnemyHandGrid.get_children():
		if slot.occupied():
			options.push_back(slot.get_card())
	choice = random.choice(options)
	return choice

func set_player_turn(value:bool):
	player_turn = false
	log_current_field()
	if ready_to_resolve():
		yield(Co.wait(1),"completed")
		yield(Co.wrap(resolve_field()),"completed")
		yield(Co.wait(0.5),"completed")
		if is_game_ended():
			emit_signal("gameover")
			return

	if value:
		var text = "%s's Turn"%Loc.tr(player_data.name)
		PlayBanner(Team.PLAYER, text, "turn_start")
		yield(Banner.tween,"tween_completed")
		PlayerSprite.animate_turn()

		if can_draw_card(Team.PLAYER):
			draw_card(Team.PLAYER)
			yield(self,"card_drawn")
			set_focus_buttons()
	else:
		emit_signal("enemyturn")
		yield(Co.wait(0.5),"completed")
		PlayerSprite.animate_turn_end()
	player_turn = value

func log_current_field():
	var enemy_slots:Array = []
	var player_slots:Array = []
	var index:int = 1
	for slot in EnemyField.get_children():
		if slot.occupied():
			enemy_slots.push_back("Slot %s: %s"%[str(index), slot.card_info.name])
		else:
			enemy_slots.push_back("Slot %s: Vacant"%str(index))
		index+=1
	console_log("""
	Enemy Field
	%s | %s | %s"""%[enemy_slots[0],enemy_slots[1],enemy_slots[2]])
	for slot in PlayerField.get_children():
		if slot.occupied():
			player_slots.push_back("Slot %s: %s"%[str(index), slot.card_info.name])
		else:
			player_slots.push_back("Slot %s: Vacant"%str(index))
		index+=1
	console_log("""
	%s | %s | %s
	Player Field"""%[player_slots[0],player_slots[1],player_slots[2]])


func get_winner_name()->String:
	var result:String =  ""
	if player_stats.hp > 0:
		if demo:
			result = "Nate"
		else:
			result = SaveState.party.player.name
	else:
		result = Loc.tr(enemy_data.name)
	return result

func can_draw_card(team)->bool:
	var grid = PlayerHandGrid if team == Team.PLAYER else EnemyHandGrid
	for slot in grid.get_children():
		if !slot.occupied():
			return true
	return false

func build_demo_deck(_team:int)->Array:
	var deck:Array = []
	var forms = MonsterForms.by_index
	for _i in range (0,30):
		var form = forms.pop_front()
		var card = card_template.instance()
		if _team == 1:
			card.enemy = true
		card.form = form.resource_path
		if demo and _team == 1 and _i == 0:
			card.form = "res://data/monster_forms/nevermort.tres"
		if demo and _team == 1 and _i == 1:
			card.form = "res://data/monster_forms/apocrowlypse.tres"
		deck.push_back(card.duplicate())

#	deck.shuffle()
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

func get_player_deck()->Array:
	var result:Array = []
	var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	if !manager.has_savedata():
		manager.initialize_savedata()
	var collection = manager.get_card_collection()
	for item in collection.values():
		var load_test = load(item.path)
		if !load_test:
			continue
		if item.deck > 0:
			for _i in range(0,item.deck):
				var card = card_template.instance()
				card.form = item.path
				card.holocard = item.holocard
				result.push_back(card.duplicate())
	return result


func animate_hover_enter(node):
	if tween.is_active():
		yield(tween,"tween_completed")
	tween.interpolate_property(node,"rect_scale",rect_scale,Vector2(1.2,1.2),.3,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.start()
func animate_hover_exit(node):
	if tween.is_active():
		yield(tween,"tween_completed")
	tween.interpolate_property(node,"rect_scale",rect_scale,Vector2.ONE,.3,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	tween.start()
