extends "res://menus/BaseMenu.gd"
signal enemyturn
signal gameover
signal field_cleared
signal hand_drawn
signal card_drawn
signal thinking_complete

enum DamageType {NEUTRAL, DAMAGE, HEAL}

const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
const manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
const damage_pop = preload("res://mods/LivingWorld/cardgame/damage_pop.tscn")
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

export (Dictionary) var player_setup
export (Dictionary) var enemy_setup
export (int) var deck_seed
export (Dictionary) var player_data
export (Dictionary) var enemy_data
export (bool) var demo = false
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
var player_stats:Dictionary = {"max_hp":6,"hp":6,"state":State.NEUTRAL,"attack":0,"defense":0,"attack_value":0,"defense_value":0}
var enemy_stats:Dictionary = {"max_hp":6,"hp":6,"state":State.NEUTRAL,"attack":0,"defense":0,"attack_value":0,"defense_value":0}
var winner_name:String
var enemy_tween:Tween
var player_tween:Tween
var player_damage_start:Array = []
var enemy_damage_start:Array = []

func _ready():
	random = Random.new()

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
	set_player_turn(true)

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
	if enemy_data:
		EnemySprite.set_sprite(enemy_data)

func initialize_decks():
	if player_deck.empty():
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
	var player_wins:bool = winner == WorldSystem.get_player().name
	player_turn = false
	if player_wins:
		EnemySprite.animate_defeat()
	else:
		PlayerSprite.animate_defeat()
	choose_option(winner == WorldSystem.get_player().name)

func is_game_ended()->bool:
	return player_stats.hp == 0 or enemy_stats.hp == 0

func set_card_colors(card,team):
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
	return result

func resolve_stats(stats:Dictionary)->Dictionary:
	var result:Dictionary = {"attack":0,"defense":0}
	result.attack = int(stats.attack / resolve_value) if stats.state != State.DEFENSE else 0
	result.defense = int(stats.defense / resolve_value) if stats.state != State.ATTACK else 0
	return result

func update_value_labels():
	var player_result = resolve_stats(player_stats)
	PlayerAttackLabel.text = str(player_result.attack)
	PlayerDefenseLabel.text = str(player_result.defense)

	var enemy_result = resolve_stats(enemy_stats)
	EnemyAttackLabel.text = str(enemy_result.attack)
	EnemyDefenseLabel.text = str(enemy_result.defense)

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
		GameSFX.play_track("damage")
		yield(GameSFX,"finished")

	if player_result.defense > enemy_result.attack and player_stats.hp < player_stats.max_hp:
		damage = player_result.defense - enemy_result.attack
		var text = "+ %s"%str(damage)
		animate_damage_pop(Team.PLAYER,text,DamageType.HEAL)
		player_stats.hp += damage
		player_stats.hp = clamp(player_stats.hp, 0, player_stats.max_hp)
		PlayerHealth.text = str(player_stats.hp)
		GameSFX.play_track("heal")
		yield(GameSFX,"finished")


	if enemy_result.attack > player_result.defense:
		damage = enemy_result.attack - player_result.defense
		var text = "- %s"%str(damage)
		PlayerSprite.animate_damage()
		animate_heart_damage(Team.PLAYER)
		animate_damage_pop(Team.PLAYER,text,DamageType.DAMAGE)
		player_stats.hp -= damage
		player_stats.hp = clamp(player_stats.hp,0,player_stats.max_hp)
		PlayerHealth.text = str(player_stats.hp)
		GameSFX.play_track("damage")
		yield(GameSFX,"finished")

	if enemy_result.defense > player_result.attack and enemy_stats.hp < enemy_stats.max_hp:
		damage = enemy_result.defense - player_result.attack
		var text = "+ %s"%str(damage)
		animate_damage_pop(Team.ENEMY,text,DamageType.HEAL)
		enemy_stats.hp += damage
		enemy_stats.hp = clamp(enemy_stats.hp,0,enemy_stats.max_hp)
		EnemyHealth.text = str(enemy_stats.hp)
		GameSFX.play_track("heal")
		yield(GameSFX,"finished")
	if enemy_result.defense == player_result.attack and player_result.attack != 0:
		animate_damage_pop(Team.ENEMY,"Blocked!",DamageType.NEUTRAL)
		GameSFX.play_track("blocked")
		yield(GameSFX,"finished")
	if player_result.defense == enemy_result.attack and enemy_result.attack != 0:
		animate_damage_pop(Team.PLAYER,"Blocked!",DamageType.NEUTRAL)
		GameSFX.play_track("damage")
		yield(GameSFX,"blocked")
	reset_stats()
	yield(Co.wait(2),"completed")
	clear_battlefield()
	yield(self,"field_cleared")
	update_value_labels()
	set_state(enemy_stats.state,Team.ENEMY)
	set_state(player_stats.state,Team.PLAYER)


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
		var movepos = EnemyDeck.rect_global_position
		enemy_discard.push_back(slot.get_card().duplicate())
		slot.get_card().animate_playcard(movepos,0.1)
		yield(slot.get_card().tween,"tween_all_completed")
		slot.clear_slot()

	for slot in PlayerField.get_children():
		var movepos = PlayerDeck.rect_global_position
		player_discard.push_back(slot.get_card().duplicate())
		slot.get_card().animate_playcard(movepos,0.1)
		yield(slot.get_card().tween,"tween_all_completed")
		slot.clear_slot()

	emit_signal("field_cleared")

func reset_stats():
	player_stats.attack = 0
	player_stats.defense = 0
	player_stats.defense_value = 0
	player_stats.attack_value = 0
	enemy_stats.attack = 0
	enemy_stats.defense = 0
	enemy_stats.defense_value = 0
	enemy_stats.attack_value = 0

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
	card.animate_playcard(move_pos,0.2)
	var remaster_bonus:bool = check_remasters(PlayerField,card)
	yield(card.tween,"tween_completed")

	if card.has_node("Button"):
		var button = card.get_node("Button")
		card.remove_child(button)
	empty_slot.set_card(card)
	if remaster_bonus:
		Banner.set_colors(Team.PLAYER)
		Banner.set_text("Remaster Bonus!")
		var co_list:Array = []
		co_list.push_back(GameSFX.play_track("remaster"))
		co_list.push_back(Banner.animate_banner(BannerStart.global_position,BannerEnd.global_position,1.5))
		yield(Co.join(co_list),"completed")
		yield(Banner.tween,"tween_completed")
	if active_field(Team.PLAYER):
		player_stats = evaluate_state(Team.PLAYER, card, remaster_bonus)
		set_state(player_stats.state,Team.PLAYER)
		update_value_labels()
	set_focus_buttons()
	set_player_turn(false)
	yield(Co.wait(0.5),"completed")
	emit_signal("enemyturn")
	PlayerSprite.animate_turn_end()

func set_state(state,team):
	var label = PlayerState if team == Team.PLAYER else EnemyState
	if state == State.NEUTRAL:
		label.text = "LIVINGWORLD_CARDS_UI_NEUTRAL"
	if state == State.ATTACK:
		label.text = "LIVINGWORLD_CARDS_UI_ATTACK"
	if state == State.DEFENSE:
		label.text = "LIVINGWORLD_CARDS_UI_DEFENSE"

func get_empty_slot(container):
	var result = null
	for slot in container.get_children():
		if !slot.occupied():
			result = slot
			break
	return result

func draw_card(team):
	var hand = PlayerHandGrid if team == Team.PLAYER else EnemyHandGrid
	var deck:Array = player_deck if team == Team.PLAYER else enemy_deck
	var discard:Array = player_discard if team == Team.PLAYER else enemy_discard
	var card = deck.pop_front() if !deck.empty() else refresh_deck(deck,discard)
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
	yield(card.tween,"tween_all_completed")
	hand_slot.set_card(card)
	if team == Team.PLAYER:
		setup_button(card)
		card.flip_card(0.1)
		yield(card.tween,"tween_all_completed")
	emit_signal("card_drawn")
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
	Banner.set_colors(Team.ENEMY)
	Banner.set_text("%s's Turn"%enemy_data.name)
	var co_list:Array = []
	co_list.push_back(GameSFX.play_track("turn_start"))
	co_list.push_back(Banner.animate_banner(BannerStart.global_position,BannerEnd.global_position,1.5))
	yield(Co.join(co_list),"completed")
	yield(Banner.tween,"tween_completed")
	if can_draw_card(Team.ENEMY):
		draw_card(Team.ENEMY)
		yield(self,"card_drawn")

	var card = evaluate_situation()

	if manager.get_setting("EnemyCardThought"):
		animate_thinking(card)
		yield(self,"thinking_complete")
	card.flip_card(0.1)
	yield(Co.wait(0.3),"completed")
	var empty_slot = get_empty_slot(EnemyField)
	var move_pos = empty_slot.get_global_rect().position
	var remaster_bonus:bool = check_remasters(EnemyField,card)
	card.animate_playcard(move_pos,0.2)
	yield(card.tween,"tween_completed")
	empty_slot.set_card(card)
	if remaster_bonus:
		Banner.set_colors(Team.ENEMY)
		Banner.set_text("Remaster Bonus!")
		co_list = []
		co_list.push_back(GameSFX.play_track("turn_start"))
		co_list.push_back(Banner.animate_banner(BannerStart.global_position,BannerEnd.global_position,1.5))
		yield(Co.join(co_list),"completed")
		yield(Banner.tween,"tween_completed")
	if active_field(Team.ENEMY):
		enemy_stats = evaluate_state(Team.ENEMY,card,remaster_bonus)
		set_state(enemy_stats.state,Team.ENEMY)
		update_value_labels()
	yield(Co.wait(0.5),"completed")
	EnemySprite.animate_turn_end()
	set_player_turn(true)

func check_remasters(field, new_card)->bool:
	var result:bool = false
	for card_slot in field.get_children():
		if !card_slot.occupied():
			continue
		var card = card_slot.get_card()
		var form = load(card.form)
		var new_card_form = load(new_card.form)
		if form.evolutions.size() > 0:
			for evo in form.evolutions:
				if evo.evolved_form == new_card_form and !card.card_info.remastered:
					result = true
					card.card_info.remastered = true
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
	stats.attack += card.card_info.attack
	stats.defense += card.card_info.defense
	if stats.attack > stats.defense:
		stats.state = State.ATTACK

	if stats.defense > stats.attack:
		stats.state = State.DEFENSE

	if stats.defense == stats.attack:
		stats.state = State.NEUTRAL

	if bonus:
		stats.attack += resolve_value
		stats.defense += resolve_value
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
	var in_danger:bool = enemy_stats.hp < enemy_stats.max_hp / 3

	var defensive:bool = random.rand_bool(0.7) if in_danger else random.rand_bool(0.3)
	var offensive:bool = random.rand_bool(0.8) if !defensive else false

	if defensive:
		return get_card(State.DEFENSE)
	if offensive:
		return get_card(State.ATTACK)
	return get_random()

func get_random():
	var choice = null
	var options = []
	for slot in EnemyHandGrid.get_children():
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
		Banner.set_colors(Team.PLAYER)
		Banner.set_text("%s's Turn"%player_data.name)
		var co_list:Array = []
		co_list.push_back(GameSFX.play_track("turn_start"))
		co_list.push_back(Banner.animate_banner(BannerStart.global_position,BannerEnd.global_position,1.5))
		yield(Co.join(co_list),"completed")
		yield(Banner.tween,"tween_completed")
		PlayerSprite.animate_turn()

		if can_draw_card(Team.PLAYER):
			draw_card(Team.PLAYER)
			yield(self,"card_drawn")
			set_focus_buttons()
	player_turn = value

func get_winner_name()->String:
	var result:String =  ""
	if player_stats.hp > 0:
		result = WorldSystem.get_player().name
	else:
		result = enemy_data.name
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
	for _i in range (0,25):
		var form = forms.pop_front()
		var card = card_template.instance()
		card.form = form.resource_path
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
		if item.deck > 0:
			for _i in range(0,item.deck):
				var card = card_template.instance()
				card.form = item.path
				result.push_back(card.duplicate())
	return result


