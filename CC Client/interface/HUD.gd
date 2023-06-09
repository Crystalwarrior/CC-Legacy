extends Control

var recent_unfocused = false

func _ready():
	Network.connect("message_received", self, "_on_message_received")

func _input(event):
	var input = get_node("chat/input")
	if not input.has_focus() and event.is_action_released("chat"):
		if recent_unfocused:
			recent_unfocused = false
		else:
			input.grab_focus()
	
	if event.is_action_released("chat_focus"):
#		if input.has_focus():
#			input.release_focus()
#		else:
		input.grab_focus()

remote func newline_message(new_text):
	get_node("chat/output").text += '\n ' + new_text

remote func append_message(new_text):
	get_node("chat/output").text += new_text

func _on_chat_send_pressed():
	var input = get_node("chat/input")
	if (input.text != ''):
		var msg = Network.self_data.name + ': ' + input.text
		Network.rpc("send_message", msg)
		newline_message(msg)
	input.text = ''
	input.release_focus()
	recent_unfocused = true

func _on_chat_text_entered(new_text):
	var input = get_node("chat/input")
	if (input.text != ''):
		var msg = Network.self_data.name + ': ' + new_text
		Network.rpc("send_message", msg)
		newline_message(msg)
	input.text = ''
	input.release_focus()
	recent_unfocused = true

func _on_message_received(text):
	newline_message(text)
	
func _on_health_changed(value):
	get_node("health").set_value(value)

##INVENTORY##

func _on_inventory_changed(value):
	pass
