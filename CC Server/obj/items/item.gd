extends Area2D

signal interact_tracked(user)
signal interact_untracked(user)
signal interact(user)

remote func update_object_state(peer=null):
#	if peer != null:
#		rpc_id(peer, "interact_object") #specific client update
#	else:
#		print("global update for door ", name, " state")
#		rpc("interact_object") #global update
	pass

remote func interact_object():
	print("item boi interacted with")

func _on_interact(user):
	pass
#	update_door_state(not open)

func _on_interact_tracked(user):
	pass

func _on_interact_untracked(user):
	pass
