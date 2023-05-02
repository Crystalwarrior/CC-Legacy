extends "res://gamemode/Default.gd"

var king = null
var win_time = 60

onready var king_timer = $KingTimer

func _ready():
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func start():
	.start()
	$PickTimer.start()

#func end():
#	.end()

func onSpawn(player):
	player.set_weapon("res://character/weapon/knife.tscn")

func onDeath(player):
	player.get_node("RespawnTimer").start()
	if player.name.to_int() == king:
		make_king(player.last_attacker)

func _on_PickTimer_timeout():
	$PickTimer.stop()
	randomize()
	var keys = Network.clients.keys()
	var net_id = keys[rand_range(0, keys.size())]
	make_king(net_id)

func _on_KingTimer_timeout():
	king_timer.stop()
	var picked = Network.clients[king]
	Network.send_message("GAME: %s is the King of the Hill!" % picked.name)
	Network.rpc("send_message", "GAME: %s is the King of the Hill!" % picked.name)
	end()

func make_king(peer_id):
	var picked = Network.clients[peer_id]
	var player = get_node("/root/Game/Players/%s" % peer_id)

	king_timer.stop()
	king_timer.wait_time = win_time
	king_timer.start()

	player.set_weapon("res://character/weapon/Kingsword.tscn")

	Network.send_message("GAME: %s is the new King! They must survive for %s seconds." % [picked.name, king_timer.wait_time])
	Network.rpc("send_message", "GAME: %s is the new King! They must survive for %s seconds." % [picked.name, king_timer.wait_time])
	
	king = peer_id