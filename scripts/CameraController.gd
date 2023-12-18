extends Spatial
enum DIRECTION {UP,DOWN,LEFT,RIGHT,FORWARD,BACK}
var positions:Array = [Vector3(0,1,0),Vector3(0,-1,0),Vector3(-1,0,0),Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,0,1)]
var weight:float = 1.0
var original_targets
func _ready():
	original_targets = SceneManager.current_scene.tracker.targets

func _process(_delta):
	var pawn = get_parent()
	weight = 0.2 if Input.is_key_pressed(KEY_SHIFT) else 1.0
	if Input.is_key_pressed(KEY_S):
		pawn.global_transform.origin = move_camera(pawn.global_transform.origin, positions[DIRECTION.BACK])
	if Input.is_key_pressed(KEY_W):
		pawn.global_transform.origin = move_camera(pawn.global_transform.origin, positions[DIRECTION.FORWARD])	
	if Input.is_key_pressed(KEY_A):
		pawn.global_transform.origin = move_camera(pawn.global_transform.origin, positions[DIRECTION.LEFT])
	if Input.is_key_pressed(KEY_D):
		pawn.global_transform.origin = move_camera(pawn.global_transform.origin, positions[DIRECTION.RIGHT])
	if Input.is_key_pressed(KEY_PAGEDOWN):
		pawn.global_transform.origin = move_camera(pawn.global_transform.origin, positions[DIRECTION.DOWN])
	if Input.is_key_pressed(KEY_PAGEUP):
		pawn.global_transform.origin = move_camera(pawn.global_transform.origin, positions[DIRECTION.UP])
	if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		reset_camera()

func move_camera(current_position, offset:Vector3):
	var old_pos = current_position
	var new_pos = current_position + offset
	remove_target()
	return lerp(old_pos,new_pos, weight)	


func reset_camera():
	var pawn = get_parent()
	var old_pos = pawn.global_transform.origin

	SceneManager.current_scene.tracker.set_targets(original_targets)
	pawn.translation = lerp(old_pos,Vector3.ZERO, weight)
	
func set_player_control(enabled:bool):
	WorldSystem.set_flag(WorldSystem.WorldFlags.PLAYER_CONTROL_ENABLED, enabled)

func remove_target():
	var tracker = WorldSystem.get_level_map().get_node("Tracker")						
	tracker.set_targets([])
