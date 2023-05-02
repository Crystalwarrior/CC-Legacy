extends Button

func _on_StartGame_pressed():
	var current = "/root/Game/ModeManager/%s" % $"/root/Game/ModeManager/".current
	if has_node(current) and get_node(current).running:
		$"/root/Game/ModeManager".end_game()
		if not get_node(current) or not get_node(current).running:
			text = "Start Game"
	else:
		$"/root/Game/ModeManager".start_game()
		current = "/root/Game/ModeManager/%s" % $"/root/Game/ModeManager/".current
		if has_node(current) and get_node(current).running:
			text = "Stop Game"