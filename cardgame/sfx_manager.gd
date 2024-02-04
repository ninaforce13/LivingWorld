extends AudioStreamPlayer2D

export (Dictionary) var sfx

func _ready():
	pass

func play_track(track):
	if sfx.has(track):
		stream = sfx[track]
		play()
