extends Control
signal reward_completed
export (String) var reward_monster_path

onready var spawnpoint = find_node("CardSpawn")
onready var endpoint = find_node("CardEndPoint")

var card_template = preload("res://mods/LivingWorld/cardgame/CardTemplate.tscn")
var reward_card = null


func _ready():
	reward_card = card_template.instance()
	reward_card.form = reward_monster_path
	add_child(reward_card)
	reward_card.rect_global_position = spawnpoint.global_position
	animate_card(2)

func animate_card(duration):
	var tween:Tween = Tween.new()
	add_child(tween)
	if tween:
		tween.stop_all()
		tween.interpolate_property(reward_card,"rect_global_position",spawnpoint.global_position,endpoint.global_position,duration,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
		tween.start()

	while tween.is_active():
		reward_card.flip_card_hidden(0.2)
		yield(reward_card.tween,"tween_all_completed")
	reward_card.flip_card(0.3)
	yield(reward_card.tween,"tween_all_completed")
	tween.interpolate_property(reward_card,"rect_scale",rect_scale,Vector2(1.4,1.4),0.5,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_all_completed")
	yield(Co.wait(1),"completed")
	tween.interpolate_property(reward_card,"rect_scale",rect_scale,Vector2(0.7,0.7),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	tween.interpolate_property(reward_card,"rect_global_position",reward_card.rect_global_position,spawnpoint.global_position,1,Tween.TRANS_ELASTIC,Tween.EASE_IN)
	tween.start()

	yield(tween,"tween_all_completed")
	emit_signal("reward_completed")









