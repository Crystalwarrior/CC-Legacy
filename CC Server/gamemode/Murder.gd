extends "res://gamemode/Default.gd"

var killer = null

var alive = []
var dead = []

func _ready():
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func start():
	.start()
	Network.send_message("GAME: A new round of Murder has started! The killer shall be picked in 10 seconds...")
	Network.rpc("send_message", "GAME: A new round of Murder has started! The killer shall be picked in 10 seconds...")
	$PickTimer.start()

func end():
	var living = alive.size()
	if living > 1:
		Network.send_message("GAME: The game ends with %s survivors." % living)
		Network.rpc("send_message", "GAME: The game ends with %s survivors." % living)
	elif living == 1:
		Network.send_message("GAME: The game is over. Only %s remains alive!" % Network.clients[alive[0].name.to_int()].name)
		Network.rpc("send_message", "GAME: The game is over. Only %s remains alive!" % Network.clients[alive[0].name.to_int()].name)
	else:
		Network.send_message("GAME: And then, there were none.")
		Network.rpc("send_message", "GAME: And then, there were none.")
	.end()

func onSpawn(player):
	dead.erase(player)
	alive.append(player)

func onRespawn(player):
	if not $EndTimer.is_stopped():
		return
	player.rpc("freecam") #we make this bitch freecam

func onDeath(player):
	player.get_node("RespawnTimer").start() #todo: make this the "spectate" timeout
	dead.append(player)
	alive.erase(player)
	
	if alive.size() <= 1:
		$EndTimer.start()

func make_killer(peer_id):
	var picked = Network.clients[peer_id]
	var player = get_node("/root/Game/Players/%s" % peer_id)

	player.set_weapon("res://character/weapon/knife.tscn")

	Network.send_message("GAME: The killer has been decided. Let the game begin!")
	Network.rpc("send_message", "GAME: The killer has been decided. Let the game begin!")
	Network.rpc_id(peer_id, "send_message", "GAME: You are the killer!")

	killer = peer_id

func _on_EndTimer_timeout():
	$EndTimer.stop()
	end()

func _on_PickTimer_timeout():
	$PickTimer.stop()
	randomize()
	var keys = Network.clients.keys()
	var net_id = keys[rand_range(0, keys.size())]
	make_killer(net_id)
