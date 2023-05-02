extends Node

var running = false
var min_players = 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func start():
	if Network.clients.size() < min_players:
		Network.send_message("GAME: Not enough players for %s!" % name)
		Network.rpc("send_message", "GAME: Not enough players for %s!" % name)
		queue_free()
		return

	running = true
	for peer_id in Network.clients:
		if has_node("/root/Game/Players/%s" % peer_id):
			var player = get_node("/root/Game/Players/%s" % peer_id)
			player.spawn(Network.clients[peer_id].character) #respawn everyone

	Network.send_message("GAME: Starting new game of %s!" % name)
	Network.rpc("send_message", "GAME: Starting new game of %s!" % name)

func end():
	for peer_id in Network.clients:
		if has_node("/root/Game/Players/%s" % peer_id):
			var player = get_node("/root/Game/Players/%s" % peer_id)
			player.spawn(Network.clients[peer_id].character) #respawn everyone
	running = false
	queue_free()

func onSpawn(player):
	pass

func onDeath(player):
	pass

func onRespawn(player):
	player.spawn(player.character) #we're doing this here to be replacable