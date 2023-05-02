extends Area2D

signal interact(user)

var open = false

remote func update_object_state(peer=null):
	if peer != null:
		rpc_id(peer, "update_door_state", open) #specific client update
	else:
		print("global update for door ", name, " state", open)
		rpc("update_door_state", open) #global update

remote func update_door_state(tog):
	if tog:
		set_modulate(Color(1, 1, 1, 0.5))
		get_node("DoorBody/Collision").disabled = true
		get_node("DoorBody/Occluder").set_occluder_light_mask(0)
	else:
		set_modulate(Color(1, 1, 1, 1))
		get_node("DoorBody/Collision").disabled = false
		get_node("DoorBody/Occluder").set_occluder_light_mask(1)
	open = tog
	#update the door state for all clients
	update_object_state()

func _on_interact(user):
	pass
#	update_door_state(not open)