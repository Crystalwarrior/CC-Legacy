extends Area2D

signal interact_tracked(user)
signal interact_untracked(user)
signal interact(user)

var open = false

onready var sound = get_node("Sound")

#Called from server to us
remote func update_door_state(tog):
	if tog:
		set_modulate(Color(1, 1, 1, 0.5))
		get_node("DoorBody/Collision").disabled = true
		get_node("DoorBody/Occluder").set_occluder_light_mask(0)
		sound.stream = load("res://sounds/sndDoorOpen.wav")
	else:
		set_modulate(Color(1, 1, 1, 1))
		get_node("DoorBody/Collision").disabled = false
		get_node("DoorBody/Occluder").set_occluder_light_mask(1)
		sound.stream = load("res://sounds/sndDoorClose.wav")
	sound.play()
	open = tog

func _on_interact_tracked(user):
	set_modulate(Color(0.5, 0.5, 0.5, modulate[3]))

func _on_interact_untracked(user):
	set_modulate(Color(1, 1, 1, modulate[3]))

#Tell the server to update door and send back its proper state to everyone
func _on_interact(user):
	rpc_id(1, "update_door_state", not open)