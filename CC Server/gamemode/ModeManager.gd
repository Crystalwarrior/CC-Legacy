extends Node

export(String) var current

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func start_game():
	if has_node(current):
		get_node(current).start()
	else:
		var mode = load('res://gamemode/%s.tscn' % current).instance()
		add_child(mode)
		get_node(current).start()

func end_game():
	if has_node(current):
		get_node(current).end() #calls queue_free most likely
	else:
		Network.send_message("ERROR: Failed to end game mode %s!" % current)
		Network.rpc("send_message", "ERROR: Failed to end game mode %s!" % current)
		print("ERROR: Failed to end game mode %s!" % current)

func onSpawn(player):
	if has_node(current):
		get_node(current).onSpawn(player)

func onRespawn(player):
	if has_node(current):
		get_node(current).onRespawn(player)

func onDeath(player):
	if has_node(current):
		get_node(current).onDeath(player)
