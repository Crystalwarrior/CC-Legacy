extends KinematicBody2D

signal direction_changed(new_direction)
signal avatar_changed(type, value)

export var BASE_SPEED = 96.0

var input_allowed = true

var input_direction = Vector2() setget set_input_direction
var look_direction = Vector2(0, 1) setget set_look_direction

var body = null
var head = null
var hair = null

remote var server_pos = Vector2()

var health = null

var character = null

var dead = false

var weapon = null

var sound = null

#=========#CORE FUNCS#=========#

remote func spawn(chr):
	print("Spawning char for ", Network.self_data.name)

	set_weapon(null)

	if is_network_master():
		$"/root/Game/Interface/fov".visible = true
		get_node("Camera").make_current()
		if has_node("Health") and get_node("/root").has_node("Game") and get_node("/root/Game/Interface").has_node("HUD/health"):
			var hp = get_node("/root/Game/Interface/HUD/health")
			health.connect("health_changed", get_node("/root/Game/Interface/HUD"), "_on_health_changed")
		if has_node("Inventory") and get_node("/root").has_node("Game") and get_node("/root/Game/Interface").has_node("HUD/inventory"):
			var inventory = get_node("/root/Game/Interface/HUD/inventory")
			inventory.connect("inventory_changed", get_node("/root/Game/Interface/HUD"), "_on_inventory_changed")
		if get_node("/root/Game/Interface").has_node("fov"):
			var fov = get_node("/root/Game/Interface/fov")
			connect("direction_changed", fov, '_on_Player_direction_changed')
		
		input_allowed = true

	character = chr
	set_shirt_color(character.shirt_color)
	set_pants_color(character.pants_color)
	set_eye_color(character.eye_color)
	set_hair_name(character.hair_name)
	set_hair_color(character.hair_color)

	dead = false
	get_node("GlobalAnim").play("root")

	health.set_health(health.Max)

func _ready():
	head = get_node("Pivot/Head")
	hair = get_node("Pivot/Hair")
	body = get_node("Pivot/Body")

	health = get_node("Health")
	
	sound = get_node("Sound")
	
	if get_tree().has_network_peer() and not is_network_master():
		sound.bus = "Reverb"

func _input(event):
	var chatting = false
	if get_node("/root").has_node("Game") and get_node("/root/Game/Interface").has_node("HUD/chat"):
		chatting = get_node("/root/Game/Interface/HUD/chat/input").has_focus()
	if not input_allowed or chatting or dead:
		return
	if not get_tree().has_network_peer() or is_network_master():
		if get_node("InteractArea")._tracked_item and event.is_action_pressed("interact"):
			if get_tree().has_network_peer():
				rpc_id(1, "interact", get_node("InteractArea")._tracked_item.get_path())
			interact(get_node("InteractArea")._tracked_item.get_path())

master func freecam(): #only master of this node gets freecam'd
	input_allowed = false
	var cam = $"/root/Game/FreeCam"
	$"/root/Game/Interface/fov".visible = false
	cam.global_position = self.global_position
	cam.make_current()

var running = false
var attacking = false
var last_run_pressed = 0
var syncing = 0

var step = 0
func _physics_process(delta):
	var chatting = false
	if get_node("/root").has_node("Game") and get_node("/root/Game/Interface").has_node("HUD/chat"):
		chatting = get_node("/root/Game/Interface/HUD/chat/input").has_focus()
	if not get_tree().has_network_peer() or is_network_master():
		
		input_direction = Vector2()
		var run_pressed = false
		var run_released = false
		var move_lock = false
		var attack_pressed = false
		
		var speed = BASE_SPEED
		
		if input_allowed and not chatting and not dead:
			input_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			input_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
			move_lock = Input.is_action_pressed("move_lock")
			run_pressed = Input.is_action_pressed("move_run")
			run_released = Input.is_action_just_released("move_run")
			attack_pressed = Input.is_action_pressed("attack")

		if weapon != null:
			if attack_pressed and not attacking:
				attacking = true
				if not move_lock and input_direction and look_direction != input_direction:
					set_look_direction(input_direction)
					if get_tree().has_network_peer():
						rpc("set_look_direction", input_direction)
	
				step(speed*3, look_direction)
				
				#todo: make server priority to prevent a "fake" attack from happening
				if get_tree().has_network_peer():
					$WeaponPivot.rpc_id(1, "attack")
				else:
					$WeaponPivot.attack()
	
				if get_node("Pivot/Body").current_anim != "crouch":
					play_anim("Body", "crouch")
					if get_tree().has_network_peer():
						rpc("play_anim", "Body", "crouch")
			elif attacking:
				move_lock = true
				speed /= 2
		else:
			attacking = false

		if running:
			if not move_lock and input_direction and look_direction != input_direction:
				set_look_direction(input_direction)
				if get_tree().has_network_peer():
					rpc("set_look_direction", input_direction)
			if get_node("Pivot/Body").current_anim != "run" and not attacking:
				play_anim("Body", "run")
				if get_tree().has_network_peer():
					rpc("play_anim", "Body", "run")

			var collide = step(speed*2, look_direction)
			if collide or run_released or dead:
				running = false
				play_anim("Body", "idle")
				if get_tree().has_network_peer():
					rpc("play_anim", "Body", "idle")
		elif run_pressed:
			if not move_lock and input_direction and look_direction != input_direction:
				set_look_direction(input_direction)
				if get_tree().has_network_peer():
					rpc("set_look_direction", input_direction)
			if get_node("Pivot/Body").current_anim != "crouch":
				play_anim("Body", "crouch")
				if get_tree().has_network_peer():
					rpc("play_anim", "Body", "crouch")
			last_run_pressed += delta
		elif run_released:
			if last_run_pressed >= 0.2:
				running = true
			else:
				if get_node("Pivot/Body").current_anim == "crouch":
					play_anim("Body", "idle")
					if get_tree().has_network_peer():
						rpc("play_anim", "Body", "idle")
			last_run_pressed = 0
		elif input_direction:
			var collide = step(speed, input_direction)
			if not move_lock and look_direction != input_direction:
				set_look_direction(input_direction)
				if get_tree().has_network_peer():
					rpc("set_look_direction", input_direction)
			if not attacking and body.current_anim != "walk": #and get_slide_count() > 0:
				play_anim("Body", "walk")
				if get_tree().has_network_peer():
					rpc("play_anim", "Body", "walk")
#			else:
#				if body.current_anim == "walk":
#					body.change_anim("idle")
		else:
			if not attacking and body.current_anim in ["walk", "crouch"]:
				play_anim("Body", "idle")
				if get_tree().has_network_peer():
					rpc("play_anim", "Body", "idle")
		
		if get_tree().has_network_peer():
			rpc_id(1, "syncpos", position) #no cheat protection, joy
	else:
		position = server_pos

	if get_node("Pivot/Body").current_anim == "run":
		step += delta
		if step >= 0.2:
			step = 0
			randomize()
			sound.volume_db = -10
			sound.stream = load("res://sounds/footsteps/concrete-0" + String(randi() % 4 + 1) + ".wav")
			sound.play()
	else:
		step = 0

remote func setpos(pos):
	position = pos

remote func play_anim(bodypart, anim):
#	if has_node("Pivot/" + bodypart):
	if anim == "walk" and get_node("GlobalAnim").current_animation != "walk":
		get_node("GlobalAnim").play("walk")
	elif anim == "run" and get_node("GlobalAnim").current_animation != "run":
		get_node("GlobalAnim").play("run")
	elif get_node("GlobalAnim").current_animation != "death":
		get_node("GlobalAnim").play("root")
	get_node("Pivot/" + bodypart).change_anim(anim)

remote func set_weapon(path):
	if weapon != null:
		weapon.disconnect("attack_finished", self, "_on_Weapon_attack_finished")
		$WeaponPivot/WeaponSpawn.remove_child(weapon)
		weapon.queue_free()
		weapon = null
		attacking = false
	if path:
		var weapon_instance = load(path).instance() #"res://character/weapon/knife.tscn"
	
		$WeaponPivot/WeaponSpawn.add_child(weapon_instance)
		weapon = $WeaponPivot/WeaponSpawn.get_child(0)
		
		weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")

		print("Doing a thing")

	print("Got weapon path ", path)

remote func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)

remote func set_input_direction(value):
	input_direction = value

func interact(itempath):
	var item = get_tree().get_root().get_node(itempath)
	item.emit_signal("interact", self)

func step(speed, direction):
	var velocity = Vector2()
	velocity = direction.normalized() * speed
	return move(velocity)

func move(velocity):
	move_and_slide(velocity, Vector2(), 5, 2)
	if get_slide_count() == 0:
		return
	return get_slide_collision(0)

remote func die():
	if dead:
		print("omae wa mou... shinderu")
		return

	get_node("GlobalAnim").play("death")
	dead = true
	print("oof ouch i died")

func bodyFall():
	sound.volume_db = 0
	sound.stream = load("res://sounds/Thud.wav")
	sound.play()

remote func stagger():
	if dead:
		print("omae wa mou... shinderu")
		return
	get_node("GlobalAnim").play("stagger")

#=========#SIGNALS#=========#

func _on_Weapon_attack_finished():
	attacking = false

func _on_Health_changed(value):
	pass
#	if get_tree().is_network_server() and not dead and value <= 0: #we fuckin dyin bois
#		die()
#		if get_tree().has_network_peer():
#			rpc("die")
#
func _on_Health_damaged(value):
	pass
#	if get_tree().is_network_server() and not dead:
#		stagger()
#		if get_tree().has_network_peer():
#			rpc("stagger")

func _on_RespawnTimer_timeout():
	get_node("RespawnTimer").stop()

func _on_InteractArea_item_tracked(item):
	item.emit_signal("interact_tracked", self)

func _on_InteractArea_item_untracked(item):
	item.emit_signal("interact_untracked", self)

#=========#APPEARANCE#=========#

export var hair_name = "john" setget set_hair_name
export var hair_color = Color() setget set_hair_color
export var eye_color = Color() setget set_eye_color
export var shirt_color = Color() setget set_shirt_color
export var pants_color = Color() setget set_pants_color
export var skin_color = Color() setget set_skin_color

func set_hair_name(value):
	if hair:
		hair_name = value
		hair.change_anim(hair_name)
		emit_signal("avatar_changed", "hair_name", hair_name)

func set_hair_color(color):
	if hair:
		hair_color = color
		hair._set_pixel_color(2, 0, color.darkened(0.2))
		hair._set_pixel_color(3, 0, color)
		emit_signal("avatar_changed", "hair_color", hair_color)

func set_eye_color(color):
	if head:
		eye_color = color
		head._set_pixel_color(6, 0, color.darkened(0.2))
		head._set_pixel_color(7, 0, color)
		emit_signal("avatar_changed", "eye_color", eye_color)

func set_shirt_color(color):
	if body:
		shirt_color = color
		body._set_pixel_color(5, 0, color.darkened(0.2))
		body._set_pixel_color(6, 0, color)
		emit_signal("avatar_changed", "shirt_color", shirt_color)

func set_pants_color(color):
	if body:
		pants_color = color
#		body._set_pixel_color(5, 0, color.darkened(0.2))
		body._set_pixel_color(8, 0, color)
		emit_signal("avatar_changed", "pants_color", pants_color)

func set_skin_color(color):
	if body and head:
		skin_color = color
		body._set_pixel_color(2, 0, color.darkened(0.2))
		body._set_pixel_color(3, 0, color.darkened(0.1))
		body._set_pixel_color(4, 0, color)
		head._set_pixel_color(2, 0, color.darkened(0.2))
		head._set_pixel_color(3, 0, color)
		emit_signal("avatar_changed", "skin_color", skin_color)

#random colors
func random_color_hair():
	var colors = [
	#Grays/"Blues"
	Color(0.753, 0.816, 0.816), 
	Color(0.439, 0.502, 0.565), 
	Color(0.251, 0.251, 0.376),
	Color(0.125, 0.063, 0.188),
	#Browns (light) 
	Color(0.816, 0.816, 0.69), 
	Color(0.627, 0.502, 0.376), 
	Color(0.376, 0.251, 0.251), 
	Color(0.251, 0.125, 0.125), 
	#Browns
	Color(0.878, 0.69, 0.376), 
	Color(0.753, 0.502, 0.251), 
	Color(0.627, 0.314, 0.125), 
	Color(0.251, 0, 0),
	#Orange
	Color(1, 0.502, 0.251), 
	Color(0.753, 0.251, 0), 
	Color(0.502, 0.125, 0), 
	Color(0.251, 0.063, 0),
	#Blonde
	Color(1, 1, 0.627), 
	Color(1, 0.753, 0.251), 
	Color(0.753, 0.502, 0), 
	Color(0.502, 0.251, 0),
	#Ginger
	Color(1, 0.251, 0), 
	Color(1, 0.502, 0), 
	Color(1, 0.878, 0)
	]
	randomize()
	var color = colors[randi() % colors.size()]
	color.r += 0.05 - randf() * 0.1
	randomize()
	color.g += 0.05 - randf() * 0.1
	randomize()
	color.b += 0.05 - randf() * 0.1
	return color

func random_color_eye():
	var colors = [
	#Grays/"Blues"
	Color(0.439, 0.502, 0.565), 
	Color(0.251, 0.251, 0.376),
	#Browns (light) 
	Color(0.627, 0.502, 0.376), 
	Color(0.376, 0.251, 0.251), 
	#Browns
	Color(0.878, 0.69, 0.376), 
	Color(0.753, 0.502, 0.251), 
	Color(0.627, 0.314, 0.125), 
	#Orange
	Color(0.502, 0.125, 0), 
	#Blonde
	Color(0.753, 0.502, 0), 
	Color(0.502, 0.251, 0),
	#Ginger
	Color(1, 0.502, 0), 
	Color(1, 0.878, 0),
	#Green
	Color(0.251, 0.753, 0),
	Color(0, 0.502, 0.251),
	#Teal
	Color(0, 0.753, 0.502),
	Color(0, 0.502, 0.502),
	Color(0, 0.251, 0.376),
	#Blues
	Color(0, 0.753, 1),
	Color(0, 0.251, 0.753),
	]
	randomize()
	return colors[randi() % colors.size()]

func random_color_skin():
	var colors = [
#	Color("FFEBE1"), 
	Color("F5D5C0"), 
	Color("EBB2A1"),
	Color("D4A392"),
#	Color("9D7168")
	]
	randomize()
	var skin = colors[randi() % colors.size()]
	
	return skin

func random_color_generic():
	var colors = [
	Color(0.9, 0, 0), 
	Color(0.749, 0.180, 0.482), 
	Color(0.388, 0, 0.117), 
	Color(0.133, 0.270, 0.270),
	Color(0, 0.141, 0.333), 
	Color(0.105, 0.458, 0.768), 
	Color(1, 1, 1), 
	Color(0.078, 0.078, 0.078), 
	Color(0.925, 0.513, 0.678), 
	Color(0, 0.5, 0.25), 
	Color(0.784, 0.921, 0.490), 
	Color(0.541, 0.698, 0.552), 
	Color(0.560, 0.929, 0.960), 
	Color(0.698, 0.662, 0.905), 
	Color(0.878, 0.560, 0.956), 
	Color(0.888, 0, 0), 
	Color(1, 0.5, 0), 
	Color(0.99, 0.96, 0), 
	Color(0.2, 0, 0.8), 
	Color(0, 0.471, 0.196), 
	Color(0, 0.2, 0.64), 
	Color(0.596, 0.160, 0.392), 
	Color(0.55, 0.7, 1), 
	Color(0.85, 0.85, 0.85), 
	Color(0.1, 0.1, 0.1), 
	Color(0.9, 0.9, 0.9), 
	Color(0.75, 0.75, 0.75), 
	Color(0.5, 0.5, 0.5), 
	Color(0.2, 0.2, 0.2), 
	Color(0.901, 0.341, 0.078)
	]
	randomize()
	var color = colors[randi() % colors.size()]
	color.r += 0.05 - randf() * 0.1
	randomize()
	color.g += 0.05 - randf() * 0.1
	randomize()
	color.b += 0.05 - randf() * 0.1
	return color

func random_color_pants():
	var colors = [
	Color(0.75, 0.75, 0.75),
	Color(0.2, 0.2, 0.2),
	Color(0.388, 0, 0.117),
	Color(0.133, 0.27, 0.27),
	Color(0, 0.141, 0.333),
	Color(0.078, 0.078, 0.078)
	]
	randomize()
	var color = colors[randi() % colors.size()]
	color.r += 0.05 - randf() * 0.1
	randomize()
	color.g += 0.05 - randf() * 0.1
	randomize()
	color.b += 0.05 - randf() * 0.1
	return color