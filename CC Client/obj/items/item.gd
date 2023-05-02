extends Area2D

signal interact_tracked(user)
signal interact_untracked(user)
signal interact(user)

#Called from server to us
remote func interact_object():
	set_modulate(Color(0, 1, 0, modulate[3]))

func _on_interact_tracked(user):
	set_modulate(Color(0.5, 0.5, 0.5, modulate[3]))

func _on_interact_untracked(user):
	set_modulate(Color(1, 1, 1, modulate[3]))

#Tell the server to update door and send back its proper state to everyone
func _on_interact(user):
	rpc_id(1, "interact_object")