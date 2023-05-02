extends Area2D

export var damage = 30

signal attack_finished

enum STATES { IDLE, ATTACK }
var state = null

var connected = []

var sound = null

func _ready():
	$AnimationPlayer.connect('animation_finished', self, "_on_animation_finished")
	_change_state(IDLE)
	sound = get_node("Sound")

func _change_state(new_state):
	match new_state:
		IDLE:
			set_physics_process(false)
			connected.clear()
			$AnimationPlayer.play('idle')
		ATTACK:
			set_physics_process(true)
			$AnimationPlayer.play('swing')
			if get_parent().is_network_master():
				sound.bus = "Master"
			else:
				sound.bus = "Reverb"
			randomize()
			sound.stream = load("res://sounds/sndSwing" + String(randi() % 2 + 1) + ".wav")
			sound.play()
	state = new_state

func _physics_process(delta):
	pass #We handle this in the network server

func damaged(obj):
	if get_parent().is_network_master() or obj.is_network_master():
		sound.bus = "Master"
	else:
		sound.bus = "Reverb"
	randomize()
	sound.stream = load("res://sounds/sndCut" + String(randi() % 2 + 1) + ".wav")
	sound.play()

func attack():
	_change_state(ATTACK)

func _on_animation_finished(name):
	if name == 'idle':
		return
	_change_state(IDLE)
	emit_signal("attack_finished")
