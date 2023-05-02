extends Control

var data = { name = '', character = {
	hair_name = "john",
	hair_color = Color(),
	eye_color = Color(),
	shirt_color = Color(),
	pants_color = Color(),
	skin_color = Color()  }
	}

var _port = 25565
var _ip = "127.0.0.1"

func _ready():
	$Main.visible = true
	$Join.visible = false
	$Host.visible = false

##NAVIGATION##
func _on_Join_pressed():
	$Main.visible = false
	$Host.visible = false
	$Join.visible = true

func _on_Host_pressed():
	$Main.visible = false
	$Host.visible = true
	$Join.visible = false

func _on_Back_pressed():
	$Main.visible = true
	$Join.visible = false
	$Host.visible = false

##JOINING##
func _on_JoinIP_text_changed(new_text):
	if new_text.is_empty():
		_port = 25565
		_ip = "127.0.0.1"
		return
	var split = new_text.split(':')
	_ip = split[0]
	if split.size() > 1:
		_port = int(split[1])

func _on_JoinButton_pressed():
	if data.name == "":
		$Join/Label.text = "Error! Invalid player name!"
		return
	if (not _ip.is_valid_ip_address()):
		$Join/Label.text = "Error! Invalid IP address!"
		return
	if _port == 0:
		$Join/Label.text = "Error! Invalid port!"
		return
	Network.ip = _ip
	Network.port = _port
	Network.connect_to_server(data)
	_load_game()

##HOSTING##
func _on_Port_text_changed(new_text):
	if new_text.is_empty():
		_port = 25565
		return
	_port = int(new_text)

func _on_HostButton_pressed():
	$Host/Label.text = "Error! Hosting from client disabled for this verison! Use dedicated server."
	return
#	if data.name == "":
#		$Host/Label.text = "Error! Invalid player name!"
#		return
#	if _port == 0:
#		$Host/Label.text = "Error! Invalid port!"
#		return
#	Network.port = _port
#	Network.create_server(data)
#	_load_game()

##OTHER SIGNALS##
func _on_Name_text_changed(new_text):
	data.name = new_text

##FUNCS##
func _load_game():
	get_tree().change_scene('res://Game.tscn')
