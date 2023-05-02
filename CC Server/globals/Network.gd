extends Node

var ip = '127.0.0.1'
var port = 25565
var max_clients = 16

var clients = { }

signal message_received(text)

remote func send_message(txt):
	emit_signal("message_received", txt)

func _ready():
	get_tree().connect('network_peer_connected', self, '_on_client_connected')
	get_tree().connect('network_peer_disconnected', self, '_on_client_disconnected')

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_clients)
	get_tree().set_network_peer(peer)
	print("Server created!")

func _on_client_connected(id):
	send_message("A new user has connected.")
	rpc("send_message", "A new user has connected.")

func _on_client_disconnected(id):
	send_message("User " + clients[id].name + " has disconnected.")
	rpc("send_message", "User " + clients[id].name + " has disconnected.")
	clients.erase(id)

remote func _send_client_info(id, info):
	print("Obtained client info for ", id, ", distributing it to others")
	for peer_id in clients: # for each remote player
		rpc_id(id, '_get_client_info', peer_id, clients[peer_id]) # Send player to new dude
		rpc_id(peer_id, "_get_client_info", id, info) # Send new dude to player

	# Send the absolute state of entities to our newly joined guy
	for node in get_tree().get_nodes_in_group('networked'):
		node.update_object_state(id)

	clients[id] = info

	#Spawn this nerd on the server machine
	var new_player = load('res://character/Character.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	get_node("/root/Game/Players").add_child(new_player)
	new_player.spawn(info.character)