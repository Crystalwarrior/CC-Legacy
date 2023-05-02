extends Area2D

export var damage = 25

signal attack_finished

enum STATES { IDLE, ATTACK }
var state = null

var connected = []

onready var parent = $"../../../"

func _ready():
	$AnimationPlayer.connect('animation_finished', self, "_on_animation_finished")
	_change_state(STATES.IDLE)


func _change_state(new_state):
	match new_state:
		STATES.IDLE:
			set_physics_process(false)
			connected.clear()
			$AnimationPlayer.play('idle')
		STATES.ATTACK:
			set_physics_process(true)
			$AnimationPlayer.play('swing')
	state = new_state

func _physics_process(delta):
	var areas = get_overlapping_areas()
	for area in areas:
		if not (area in connected) and area.get_name() == "HitboxArea" and area.get_parent().has_node("Health") and not area.get_parent().is_a_parent_of(self):
			area.get_parent().get_node("Health").damage(damage, parent.get_network_master())
			parent.get_node("WeaponPivot").rpc("damaged", area.get_parent()) #call damaged on weaponpivot
			connected.append(area)


remote func attack():
	_change_state(STATES.ATTACK)

func _on_animation_finished(name):
	if name == 'idle':
		return
	_change_state(STATES.IDLE)
	emit_signal("attack_finished")
