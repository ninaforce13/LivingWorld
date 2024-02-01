extends Node

export (bool) var is_captain = false
export (bool) var is_partner = false
signal engaging
var max_partners = 2
const trade_generator = preload("res://mods/LivingWorld/scripts/StickerTradeGenerator.gd")
const card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
var follow_target = null
var engaged_target = null
var conversation_partners:Array = []
var slots:Array
var engaged:bool = false setget set_engage
var recruit
var on_battle_cooldown:bool = false
var trade_offer = null
var card_deck:Array = []
var seedvalue:int = 0
var random:Random
func _ready():
	WorldSystem.time.connect("date_changed", self, "_on_date_changed")
	WorldSystem.time.connect("date_changed", self, "generate_trade")
	if !is_captain:
		generate_trade()
	if is_captain:
		max_partners = 0
	if !recruit and (is_captain or is_partner):
		generate_recruit_data()
	if is_captain or is_partner:
		call_deferred("add_emoteplayer")
	if !is_partner:
		seedvalue = randi()

	random = Random.new((recruit.name).hash() + SaveState.random_seed + seedvalue)

func build_deck():
	card_deck = []
	var forms = MonsterForms.basic_forms.values() + MonsterForms.secret_forms.values()
	var debut_forms = MonsterForms.pre_evolution.values()
	random.shuffle(forms)
	for i in range (0,30):
		var form = random.choice(forms) if i > random.rand_int(30) else random.choice(debut_forms)
		var card = card_template.instance()
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
	recruit = rangerdataparser.get_npc_snapshot(pawn)

func generate_trade():
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
			var partner_data = conversation_partners[0].get_node("RecruitData")
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
			var partner_data = partner.get_node("RecruitData")
			partner_data.remove_conversation_partner(pawn)
	conversation_partners.clear()


func full_conversation()->bool:
	check_partners()
	return conversation_partners.size() >= max_partners

func check_partners():
	for partner in conversation_partners:
		if !is_instance_valid(partner):
			conversation_partners.erase(partner)

func _on_date_changed():
	on_battle_cooldown = false

