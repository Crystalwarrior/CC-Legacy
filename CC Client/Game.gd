extends Node

var music = null

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	music = get_node("Music")
	get_viewport().audio_listener_enable_2d = true

func _on_player_disconnected(id):
	if get_node("Players").get_node(str(id)):
		get_node("Players").get_node(str(id)).queue_free()
 
func _on_server_disconnected():
	get_tree().set_network_peer(null)
	get_viewport().audio_listener_enable_2d = false
	get_tree().change_scene("res://interface/Menu.tscn")

remote func play_music(path):
	music.stream = load(path)
	music.play()

remote func stop_music():
	music.stop()
