extends KinematicBody2D

signal direction_changed(new_direction)
signal avatar_changed(type, value)

signal onSpawn(pl)
signal onRespawn(pl)
signal onDeath(pl)

export var BASE_SPEED = 96.0

var input_direction = Vector2()
var look_direction = Vector2(0, 1)

var health = null
var character = null
var input_allowed = true
var dead = false
var weapon = null

var last_attacker = null

func spawn(chr):
	print("Spawning char")

	if $WeaponPivot/WeaponSpawn.get_child_count() > 0:
		$WeaponPivot/WeaponSpawn.get_child(0).queue_free()
	weapon = null

	var spawn_points = get_node("/root/Game/SpawnPoints")
	randomize()
	rpc("setpos", spawn_points.get_node(str(randi() % spawn_points.get_children().size() + 1)).position)
	
	character = chr

	dead = false
	last_attacker = null

	health.set_health(health.Max)
	rpc("spawn", character)
	
	emit_signal("onSpawn", self)

func _ready():
	health = get_node("Health")
	self.connect('onSpawn', $"/root/Game/ModeManager/", 'onSpawn')
	self.connect('onRespawn', $"/root/Game/ModeManager/", 'onRespawn')
	self.connect('onDeath', $"/root/Game/ModeManager/", 'onDeath')

func _physics_process(delta):
	rset("server_pos", position)

func set_weapon(path):
	if weapon != null and not weapon.is_queued_for_deletion():
		weapon.disconnect("attack_finished", self, "_on_Weapon_attack_finished")
		$WeaponPivot/WeaponSpawn.remove_child(weapon)
		weapon.queue_free()
		weapon = null
	if path:
		var weapon_instance = load(path).instance() #"res://character/weapon/knife.tscn"
	
		$WeaponPivot/WeaponSpawn.add_child(weapon_instance)
		weapon = $WeaponPivot/WeaponSpawn.get_child(0)
		if not weapon.is_connected("attack_finished", self, "_on_Weapon_attack_finished"):
			weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")

	rpc("set_weapon", path)

remote func play_anim(bodypart, anim):
	pass

func _on_Weapon_attack_finished():
	pass

remote func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)

remote func set_input_direction(value):
	input_direction = value

remote func interact(itempath):
	var item = get_tree().get_root().get_node(itempath)
	item.emit_signal("interact", self)

remote func syncpos(pos):
	position = pos

remote func die():
	if dead:
		return
	emit_signal("onDeath", self)
	dead = true

remote func stagger():
	if dead:
		return

#=========#SIGNALS#=========#

func _on_Health_changed(value):
	if not dead and value <= 0: 
		die()
		rpc("die")

func _on_Health_damaged(value, attacker):
	if not dead:
		last_attacker = attacker
		if value <= 0: #we fuckin dyin bois
			die()
			rpc("die")
		else: #get staggered
			stagger()
			rpc("stagger")

func _on_RespawnTimer_timeout():
	emit_signal("onRespawn", self)
	get_node("RespawnTimer").stop()

func _on_InteractArea_item_tracked(item):
	item.emit_signal("interact_tracked", self)

func _on_InteractArea_item_untracked(item):
	item.emit_signal("interact_untracked", self)
