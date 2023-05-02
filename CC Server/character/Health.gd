extends Node

signal health_changed(value)
signal damaged(value, attacker)

export var Value = 100 setget set_health
export var Max = 100

#func _ready():

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func add_health(value):
	set_health(Value + value)

func damage(value, attacker):
	emit_signal("damaged", value, attacker)
	add_health(-value)

func set_health(value):
	Value = clamp(value, 0, Max)
	emit_signal("health_changed", value)
	rpc_id(get_network_master(), "set_health", value)