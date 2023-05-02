extends Node

signal health_changed(value)
signal damaged(value)

export var Value = 100 setget set_health
export var Max = 100

#func _ready():

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

remote func add_health(value):
	set_health(Value + value)

remote func damage(value):
	add_health(-value)
	emit_signal("damaged", value)

remote func set_health(value):
	Value = clamp(value, 0, Max)
	emit_signal("health_changed", value)
#	We will transmit health info to the one who possesses this health object
#	if get_tree() and get_tree().is_network_server() and get_network_master() != 1:
#		rpc_id(get_network_master(), "set_health", value)
