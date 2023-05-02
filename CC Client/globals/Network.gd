extends Node

var ip = '127.0.0.1'
var port = 25565

var clients = { }
var self_data = { name = '', position = Vector2(0, 0), character = {
	hair_name = "john",
	hair_color = Color(),
	eye_color = Color(),
	shirt_color = Color(),
	pants_color = Color(),
	skin_color = Color()  }
	}

signal client_disconnected
signal server_disconnected

signal message_received(text)

remote func send_message(txt):
	emit_signal("message_received", txt)

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_client_disconnected')
	get_tree().connect('connected_to_server', self, '_connected_to_server')

func connect_to_server(data):
	self_data.name = data.name
	self_data.character = data.character

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

#This is called on the client who joins.
func _connected_to_server():
	clients[get_tree().get_network_unique_id()] = self_data
	_get_client_info(get_tree().get_network_unique_id(), self_data)
	rpc_id(1, '_send_client_info', get_tree().get_network_unique_id(), self_data)

func _on_client_disconnected(id):
	clients.erase(id)

remote func _get_client_info(id, info):
	print("Received client info for ", id)
	clients[id] = info

	#TODO: redesign this bit later
	var new_player = load('res://character/Character.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	get_node("/root/Game/Players").add_child(new_player)
	new_player.spawn(info.character)

func update_position(id, position):
	clients[id].position = position