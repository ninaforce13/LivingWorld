extends Control

signal card_drawn
signal card_discarded

const gradestar:Texture = preload("res://ui/party/grade.png")
const holoeffect:Material = preload("res://mods/LivingWorld/shaders/holoeffect.tres")
onready var card_name:Label = find_node("Name")
onready var card_image:TextureRect = find_node("CardTexture")
onready var card_attack_grid:HBoxContainer = find_node("AttackGrid")
onready var card_defense_grid:HBoxContainer = find_node("DefenseGrid")
onready var cardband:PanelContainer = find_node("CardBand")
onready var card:TextureRect = find_node("Card")
onready var cardenemy:TextureRect = find_node("CardEnemy")
onready var cardback = find_node("CardBack")
onready var cardbacknotext = find_node("CardBackNoText")
onready var cardbackband:PanelContainer = find_node("CardBackBand")
onready var cardlogo:TextureRect = find_node("CardLogo")
onready var audioplayer:AudioStreamPlayer2D = find_node("AudioStreamPlayer2D")
onready var card_attack_label:Label = find_node("Attack")
onready var card_defense_label:Label = find_node("Defense")
onready var highlight_focus = find_node("Highlight")
export (Dictionary) var card_info:Dictionary = {"name":"name","texture":null,"attack":3,"defense":3,"remastered":false}
export (String) var form
export (Color) var bandcolor
export (Color) var bordercolor
export (Color) var backcolor
export (bool) var holocard
export (bool) var enemy
export (bool) var no_text
var origin
var tween:Tween

func _ready():
	set_card()
	set_colors()
	set_holoeffect()
	tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)
	origin = rect_position

func set_holoeffect():
	if holocard:
		card.material = holoeffect
	else:
		card.material = null

func get_tween()->Tween:
	return tween

func animate_playcard(endposition,duration=0.5,start_pos=rect_global_position):
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2.ONE,0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")
	tween.stop_all()
	tween.interpolate_property(self,"rect_global_position",start_pos,endposition,duration,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")
	audioplayer.play()

func discard_card(endposition,duration=0.5,start_pos=rect_global_position):
	var co_list:Array = []

	co_list.push_back(move_to(endposition,duration,start_pos))
	co_list.push_back(shrink())
	co_list.push_back(rotate(duration))
	yield(Co.join(co_list),"completed")
	yield(tween,"tween_all_completed")
	audioplayer.play()
	emit_signal("card_discarded")

func shrink():
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(0.7,0.7),0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")

func draw_card(endposition,duration=0.5,start_pos=rect_global_position):
	rect_pivot_offset.y -= 100
	var co_list:Array = []
	co_list.push_back(move_to(endposition,duration,start_pos))
	co_list.push_back(rotate(duration))

	yield(Co.join(co_list),"completed")
	yield(tween,"tween_all_completed")
	co_list.clear()
	audioplayer.play()
	rect_pivot_offset.y += 100
	emit_signal("card_drawn")

func rotate(duration):
#	if tween.is_active():
#		yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_rotation",rect_rotation,-90,duration,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")

func move_to(endposition,duration=0.5,start_pos=rect_global_position):
#	if tween.is_active():
#		yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_global_position",start_pos,endposition,duration,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")

func grow():
#	if tween.is_active():
#		yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2.ONE,0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")

func animate_hover_enter():
#	if tween.is_active():
#		yield(tween,"tween_completed")
	highlight_focus.visible = true
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(1.2,1.2),.3,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.start()

func animate_hover_exit():
#	if tween.is_active():
#		yield(tween,"tween_completed")
	highlight_focus.visible = false
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2.ONE,.3,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	tween.start()
func set_colors():
	if enemy:
		card.texture = cardenemy.texture
	if no_text:
		cardback.texture = cardbacknotext.texture

func set_card():
	if form:
		set_card_info(form)

	card_name.text = card_info.name
	card_image.texture = card_info.texture
	card_attack_label.text = str(card_info.attack)
	card_defense_label.text = str(card_info.defense)
	var count:int = 0
	for child in card_attack_grid.get_children():
		if count == card_info.attack:
			break
		child.texture = gradestar
		count +=1
	count = 0
	for child in card_defense_grid.get_children():
		if count == card_info.defense:
			break
		child.texture = gradestar
		count +=1

func set_card_info(form):
	var monster_form:MonsterForm = load(form)
	card_info.name = Loc.tr(monster_form.name)
	card_info.texture = monster_form.tape_sticker_texture
	card_info.attack = calculate_grade("attack",monster_form)
	card_info.defense = calculate_grade("defense",monster_form)

func calculate_grade(type,form:MonsterForm)->int:
	var result = 0
	if type == "attack":
		result += get_stat_value(form.melee_attack)
		result += get_stat_value(form.ranged_attack)
		result += get_stat_value(form.speed)
		result += get_stat_value(form.accuracy)
	if type == "defense":
		result += get_stat_value(form.melee_defense)
		result += get_stat_value(form.ranged_defense)
		result += get_stat_value(form.evasion)
		result += get_stat_value(form.max_hp)
	return int(clamp(result,0,100))

func get_stat_value(stat):
	if stat >= 200:
		return 3
	if stat >= 160:
		return 2
	if stat >= 120:
		return 1
	if stat >= 100:
		return 0.5
	if stat < 100:
		return -0.5
	return 0

func flip_card(duration):
	tween.stop_all()
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(0,1),duration,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")

	cardback.visible = !cardback.visible
	card.visible = !card.visible
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(1,1),duration,Tween.TRANS_CIRC,Tween.EASE_OUT)
	tween.start()

func draw_rotate(duration):
	rect_pivot_offset.y -= 100
	tween.stop_all()
	tween.interpolate_property(self,"rect_rotation",rect_rotation,-90,duration,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	rect_pivot_offset.y += 100

func flip_card_hidden(duration):
	if tween.is_active():
		yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(0,1),duration,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
	cardlogo.visible = false
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(-1,1),duration,Tween.TRANS_CIRC,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(0,1),duration,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
	cardlogo.visible = true
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(1,1),duration,Tween.TRANS_CIRC,Tween.EASE_OUT)
	tween.start()

func flip_card_no_anim():
	cardback.visible = !cardback.visible
	card.visible = !card.visible

