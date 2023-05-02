extends "res://gamemode/Default.gd"

var tagger = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
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
	if tagger == player.name.to_int():
		player.set_weapon("res://character/weapon/knife.tscn")

func onDeath(player):
	player.get_node("RespawnTimer").start()
	print(player.last_attacker)
	if player.last_attacker == tagger:
		var old_player = get_node("/root/Game/Players/%s" % tagger)
		if not old_player:
			return
		old_player.set_weapon(null)
		tagger = player.name.to_int()
		var picked = Network.clients[tagger]
		Network.send_message("GAME: %s is the new IT! They have been given a knife." % picked.name)
		Network.rpc("send_message", "GAME: %s is the new IT! They have been given a knife." % picked.name)

func _on_PickTimer_timeout():
	$PickTimer.stop()
	randomize()
	var keys = Network.clients.keys()
	var net_id = keys[rand_range(0, keys.size())]
	var picked = Network.clients[net_id]
	var player = get_node("/root/Game/Players/%s" % net_id)
	player.set_weapon("res://character/weapon/knife.tscn")
	Network.send_message("GAME: %s is the new IT! They have been given a knife." % picked.name)
	Network.rpc("send_message", "GAME: %s is the new IT! They have been given a knife." % picked.name)
	
	tagger = net_id