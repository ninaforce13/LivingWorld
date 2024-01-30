extends Control
const gradestar:Texture = preload("res://ui/party/grade.png")
onready var card_name:Label = find_node("Name")
onready var card_image:TextureRect = find_node("CardTexture")
onready var card_attack_grid:HBoxContainer = find_node("AttackGrid")
onready var card_defense_grid:HBoxContainer = find_node("DefenseGrid")
onready var cardband:PanelContainer = find_node("CardBand")
onready var card:PanelContainer = find_node("Card")
onready var cardback:PanelContainer = find_node("CardBack")
onready var cardbackband:PanelContainer = find_node("CardBackBand")
export (Dictionary) var card_info:Dictionary = {"name":"name","texture":null,"attack":3,"defense":3,"remastered":false}
export (String) var form
export (Color) var bandcolor
export (Color) var bordercolor
export (Color) var backcolor
var origin
var tween:Tween

func _ready():
	set_card()
	set_colors()
	tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)
	origin = rect_position
func animate_playcard(endposition,duration=0.5):
	tween.stop_all()
	tween.interpolate_property(self,"rect_global_position",rect_global_position,endposition,duration,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")
	rect_global_position = rect_global_position
func animate_hover_enter():
	if tween.is_active():
		yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(1.2,1.2),.3,Tween.TRANS_CIRC,Tween.EASE_IN)
	tween.start()
func animate_hover_exit():
	if tween.is_active():
		yield(tween,"tween_completed")
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2.ONE,.3,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	tween.start()

func set_colors():
	var new_styleboxflat = cardband.get_stylebox("panel").duplicate()
	new_styleboxflat.bg_color = bandcolor
	new_styleboxflat.border_color = bordercolor
	cardband.add_stylebox_override("panel",new_styleboxflat)
	var mainstylebox = card.get_stylebox("panel").duplicate()
	mainstylebox.border_color = bordercolor
	card.add_stylebox_override("panel",mainstylebox)

	var cardback_bandstylebox = cardbackband.get_stylebox("panel").duplicate()
	cardback_bandstylebox.bg_color = bandcolor
	cardback_bandstylebox.border_color = bordercolor
	cardbackband.add_stylebox_override("panel",cardback_bandstylebox)
	var cardback_mainstylebox = cardback.get_stylebox("panel").duplicate()
	cardback_mainstylebox.bg_color = backcolor
	cardback_mainstylebox.border_color = bordercolor
	cardback.add_stylebox_override("panel",cardback_mainstylebox)

func set_card():
	if form:
		set_card_info(form)

	card_name.text = card_info.name
	card_image.texture = card_info.texture
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
	var result:int = 0
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
	return int(clamp(result,1,5))

func get_stat_value(stat:int)->int:
	if stat > 160:
		return 2
	if stat > 100:
		return 1
	return 0

func flip_card(duration):
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(0,1),duration,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")
	cardback.visible = !cardback.visible
	card.visible = !card.visible
	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(1,1),duration,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func flip_card_instant():
	cardback.visible = !cardback.visible
	card.visible = !card.visible

