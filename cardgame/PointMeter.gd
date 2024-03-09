extends Control
signal fill_complete
signal animation_done
export (Color) var default_color = "a8000000"
export (Color) var fill_color = "00c5c9"

onready var first_bar:PanelContainer = find_node("bar3")
onready var second_bar:PanelContainer = find_node("bar2")
onready var third_bar:PanelContainer = find_node("bar")
onready var sfx_player:AudioStreamPlayer = find_node("FillSoundPlayer")

var filled_count:int = 0
var tween:Tween = Tween.new()

func _ready():
	add_child(tween)

func fill_bar(amount:int):


	if amount > 0 and filled_count < 1:
		animate_fillbar(first_bar)
		yield(self,"animation_done")
		filled_count +=1
		amount -= 1
	if amount > 0 and filled_count < 2:
		animate_fillbar(second_bar)
		yield(self,"animation_done")
		filled_count +=1
		amount -= 1
	if amount > 0 and filled_count < 3:
		animate_fillbar(third_bar)
		yield(self,"animation_done")
		filled_count +=1
		amount -= 1
	call_deferred("emit_signal","fill_complete")


func fill_remainder():
	fill_bar(3 - filled_count)

func animate_fillbar(bar):
	if tween.is_active():
		yield(tween,"tween_completed")
	tween.interpolate_property(bar,"rect_scale",bar.rect_scale,Vector2(1.2,1.2),0.1,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	var stylebox = bar.get_stylebox("panel")
	stylebox.bg_color = fill_color
	sfx_player.play()
	tween.interpolate_property(bar,"rect_scale",Vector2(1.2,1.2),Vector2(1,1),0.1,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)
	tween.start()
	call_deferred("emit_signal","animation_done")
#	emit_signal("animation_done")


func reset_bar():
	var panel:StyleBoxFlat

	panel = first_bar.get_stylebox("panel")
	panel.bg_color = default_color

	panel = second_bar.get_stylebox("panel")
	panel.bg_color = default_color

	panel = third_bar.get_stylebox("panel")
	panel.bg_color = default_color

	filled_count = 0

