extends Control
enum TEAM {PLAYER, ENEMY}
export (Dictionary) var player_colors
export (Dictionary) var enemy_colors

onready var panel = find_node("BannerPanel")
onready var label = find_node("BannerLabel")
var tween:Tween

func _ready():
	tween = Tween.new()
	add_child(tween)

func set_colors(team:int):
	var colors = player_colors if team == TEAM.PLAYER else enemy_colors
	var new_styleboxflat = panel.get_stylebox("panel").duplicate()
	new_styleboxflat.bg_color = colors.primarycolor
	new_styleboxflat.border_color = colors.bordercolor
	panel.add_stylebox_override("panel",new_styleboxflat)

func set_text(value:String):
	label.text = value

func animate_banner(start_pos, end_pos, duration):
	tween.stop_all()
	tween.interpolate_property(self,"rect_global_position",start_pos,end_pos,duration,Tween.TRANS_ELASTIC,Tween.EASE_OUT_IN)
	tween.start()

