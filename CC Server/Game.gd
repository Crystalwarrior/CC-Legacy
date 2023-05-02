extends Node

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')

	Network.port = 25565
	Network.create_server()

func _on_player_disconnected(id):
	print(id, " disconnected!")
	if get_node("Players").get_node(str(id)):
		get_node("Players").get_node(str(id)).queue_free()
 