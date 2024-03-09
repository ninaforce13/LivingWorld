extends Node

signal engaging
signal party_disbanded

export (bool) var is_captain = false
export (bool) var is_partner = false
export (bool) var is_player = false
export (Array,String) var signature_card_forms = []
export (String) var rouges_dialog = ""
const trade_generator = preload("res://mods/LivingWorld/scripts/StickerTradeGenerator.gd")
const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
const settings = preload("res://mods/LivingWorld/settings.tres")

var max_partners = 2
var follow_target = null
var engaged_target = null
var conversation_partners:Array = []
var party_members:Dictionary = {}
var slots:Array
var engaged:bool = false setget set_engage
var recruit
var on_battle_cooldown:bool = false
var on_card_cooldown:bool = false
var trade_offer = null
var card_deck:Array = []
var seedvalue:int = 0
var random:Random
var is_leader:bool = false

func _ready():
	if !is_captain:
		WorldSystem.time.connect("date_changed", self, "_on_date_changed")
	if !is_partner:
		seedvalue = randi()
	if !recruit:
		generate_recruit_data()

	random = Random.new((recruit.name).hash() + SaveState.random_seed + seedvalue)

	if !is_captain:
		generate_trade()
	if is_captain:
		max_partners = 0
	if is_captain or is_partner:
		call_deferred("add_emoteplayer")
	if !has_ranger_id():
		set_ranger_id()

func build_deck():
	card_deck = []
	var forms = MonsterForms.basic_forms.values() + MonsterForms.secret_forms.values()
	var debut_forms = MonsterForms.pre_evolution.values()
	random.shuffle(forms)
	for form_path in signature_card_forms:
		var card = card_template.instance()
		card.enemy = true
		card.form = form_path
		card_deck.push_back(card.duplicate())
	for i in range (settings.deck_limit - signature_card_forms.size()):
		var form = random.choice(forms) if i >= (settings.deck_limit/2) else random.choice(debut_forms)
		var card = card_template.instance()
		card.enemy = true
		card.form = form.resource_path
		card_deck.push_back(card.duplicate())
	random.shuffle(card_deck)


func add_emoteplayer():
	var pawn = get_parent()
	var emoteplayer = preload("res://mods/LivingWorld/nodes/emoteplayer.tscn").instance()
	pawn.add_child(emoteplayer)
	emoteplayer.transform = pawn.emote_player.transform
	pawn.emote_player = emoteplayer

func generate_recruit_data():
	var rangerdataparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var pawn = get_parent()
	recruit = rangerdataparser.get_npc_snapshot(pawn, is_player)

func generate_trade():
	if trade_offer:
		remove_trade(trade_offer)
	trade_offer = trade_generator.generate()
	add_child(trade_offer)
	trade_offer.connect("trade_completed",self,"remove_trade",[trade_offer])

func remove_trade(trade_offer):
	remove_child(trade_offer)
	trade_offer.queue_free()

func has_trade_offer()->bool:
	return trade_offer != null and is_instance_valid(trade_offer)

func set_engage(value):
	engaged = value
	if engaged:
		emit_signal("engaging")

func add_conversation_partner(partner):
	if !full_conversation():
		if conversation_partners.size() > 0:
			var partner_data = conversation_partners[0].get_data()
			if !partner_data.conversation_partners.has(partner):
				partner_data.conversation_partners.push_back(partner)
		if !conversation_partners.has(partner):
			conversation_partners.push_back(partner)
		if not engaged:
			set_engage(true)

func remove_conversation_partner(node):
	for partner in conversation_partners:
		if partner == node:
			conversation_partners.erase(node)
			break

func exit_conversation():
	var pawn = get_parent()
	set_engage(false)
	for partner in conversation_partners:
		if is_instance_valid(partner):
			var partner_data = partner.get_data()
			partner_data.remove_conversation_partner(pawn)
	conversation_partners.clear()


func full_conversation()->bool:
	check_partners()
	return conversation_partners.size() >= max_partners

func check_partners():
	for partner in conversation_partners:
		if !is_instance_valid(partner):
			conversation_partners.erase(partner)

func reset_battle_cooldown():
	on_battle_cooldown = false

func reset_card_cooldown():
	on_card_cooldown = false

func party_full()->bool:
	return party_members.size() == max_partners

func form_party():
	var data_node = null
	var prev_member = null
	check_partners()
	for partner in conversation_partners:
		if !is_instance_valid(partner):
			continue
		data_node = partner.get_data()
		if data_node and !data_node.has_party():
			add_party_member(data_node, data_node.recruit)
			data_node.add_party_member(self, recruit, true)
			data_node.follow_target = get_parent()
			if prev_member:
				prev_member.add_party_member(data_node,data_node.recruit)
				data_node.add_party_member(prev_member,prev_member.recruit)
			prev_member = data_node
	check_partners()
	is_leader = true

func add_party_member(data_node, data:Dictionary, leader:bool = false):
	if party_full():
		return
	var key = get_ranger_key(data)
	if !party_members.has(key):
		party_members[key] = {"node":data_node,"data":data,"leader":leader}

func remove_party_member(key):
	if party_members.has(key):
		party_members.erase(key)

func disband_party():
	var party = party_members.duplicate()
	party_members.clear()
	for member in party.values():
		if is_instance_valid(member.node):
			member.node.disband_party()
	is_leader = false
	emit_signal("party_disbanded")

func get_party_data()->Array:
	for member in party_members.values():
		if !is_instance_valid(member.node):
			var key = get_ranger_key(member.data)
			remove_party_member(key)
	return party_members.values()

func has_party()->bool:
	return !party_members.empty()

func has_ranger_id()->bool:
	if recruit.has("ranger_id"):
		return recruit.ranger_id != 0
	return false

func set_ranger_id():
	recruit["ranger_id"] = random.rand_int()

func get_ranger_key(data):
	return data.name+str(data.ranger_id)

func _on_date_changed():
	reset_battle_cooldown()
	reset_card_cooldown()
	generate_trade()
	build_deck()

func get_party_position(data)->int:
	var leader = get_party_leader()
	if !leader:
		return 0
	var position = 0
	for member in leader.get_party_data():
		if member.data.ranger_id == data.ranger_id:
			return position
		position+=1
	return 0

func get_party_leader():
	if is_leader:
		return self
	for member in get_party_data():
		if member.leader:
			return member.node

func get_party_size()->int:
	var party = get_party_data()
	return party.size()

func party_leader_invalid()->bool:
	var leader = get_party_leader()
	if !leader:
		disband_party()
		return true
	if !is_instance_valid(leader):
		disband_party()
		return true
	if !is_instance_valid(leader.get_parent()):
		disband_party()
		return true
	return false
