extends Button

var tog = false

func _on_PlayMusic_pressed():
	if tog:
		get_node("/root/Game").rpc("stop_music")
		text = "Play Music"
	else:
		get_node("/root/Game").rpc("play_music", "res://sounds/[M3] Mind of a Thief.ogg")
		text = "Stop Music"
	tog = !tog