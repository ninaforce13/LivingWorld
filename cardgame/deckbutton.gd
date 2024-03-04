extends Control

export (String) var monster_form = "res://data/monster_forms/bansheep.tres"
onready var sticker = find_node("StickerTexture")
onready var name_label = find_node("Name")
onready var attack_label = find_node("AttackLabel")
onready var defense_label = find_node("DefenseLabel")
onready var focus_highlight = find_node("Highlight")
var tween:Tween

func _ready():
	tween = Tween.new()
	add_child(tween)
	tween.name = "Tween"
	setup_display()

func setup_display():
	var form:MonsterForm = load(monster_form)

	sticker.texture = form.tape_sticker_texture
	name_label.text = Loc.tr(form.name)

func set_attack(value):
	attack_label.text = str(value)

func set_defense(value):
	defense_label.text = str(value)

func animate_hover_enter():
	focus_highlight.visible = true
#	if tween.is_active():
#		yield(tween,"tween_all_completed")
#	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2(1.2,1.2),.3,Tween.TRANS_CIRC,Tween.EASE_IN)
#	tween.start()
func animate_hover_exit():
	focus_highlight.visible = false
#	if tween.is_active():
#		yield(tween,"tween_all_completed")
#	tween.interpolate_property(self,"rect_scale",rect_scale,Vector2.ONE,.3,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
#	tween.start()

