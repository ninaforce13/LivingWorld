extends Control
enum DamageType {NEUTRAL, DAMAGE, HEAL}
onready var DamageNumber = find_node("DamageNumber")
const heal_color = Color.green
const damage_color = Color.red
const neutral_color = Color.gray
export (DamageType) var type = DamageType.NEUTRAL
export (String) var text = ""

var anim:AnimationPlayer
func _ready():
	var font_color
	if type == DamageType.DAMAGE:
		font_color = damage_color
	if type == DamageType.HEAL:
		font_color = heal_color
	if type == DamageType.NEUTRAL:
		font_color = neutral_color
	DamageNumber.text = text
	DamageNumber.add_color_override("font_color",font_color)
	anim = get_node("AnimationPlayer")

func animate_pop():
	anim.play("damage")


func remove():
	var parent = get_parent()
	parent.remove_child(self)
	queue_free()
