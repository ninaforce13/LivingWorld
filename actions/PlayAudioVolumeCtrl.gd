extends Action

export (AudioStream) var stream:AudioStream
export (float) var random_pitch:float = 1.1
export (bool) var wait_for_finish:bool = true
export (bool) var mute_music:bool = false
export (String) var bus:String = "SoundEffects"
export (Array,float) var distance_thresholds = [50,40,30,20,10]
export (Array,float) var volume_db_settings = [-25,-20,-15,-10,-5]
var audio_player:AudioStreamPlayer
var volume_db = -100
func _run():
	if stream and stream.resource_path == "res://sfx/transform.wav" and not UserSettings.audio_transform:
		return true
	var player = WorldSystem.get_player()
	var distance = get_pawn().global_transform.origin.distance_to(player.global_transform.origin)
	var index:int = 0
	for dist in distance_thresholds:
		if distance < dist:
			volume_db = volume_db_settings[index]
		index+=1
	if values.size() > 0 and values[0] != null:
		audio_player = values[0]
		if stream != null:
			audio_player.stream = AudioStreamRandomPitch.new()
			audio_player.stream.random_pitch = random_pitch
			audio_player.stream.audio_stream = stream
		elif audio_player.stream == null:
			return true
	elif audio_player == null:
		if stream == null:
			return true
		audio_player = AudioStreamPlayer.new()
		audio_player.stream = AudioStreamRandomPitch.new()
		audio_player.stream.random_pitch = random_pitch
		audio_player.stream.audio_stream = stream
		audio_player.volume_db = volume_db
		audio_player.bus = bus
		add_child(audio_player)
	audio_player.play()
	if mute_music and not MusicSystem.mute:
		MusicSystem.mute = true
		Co.wait_for_audio(audio_player).connect("completed", MusicSystem, "set_mute", [false], CONNECT_ONESHOT)
	return true

func _exit_action(_result):
	if wait_for_finish and audio_player and audio_player.is_playing():
		yield (Co.safe_wait_for_audio(self, audio_player), "completed")
