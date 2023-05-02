extends Control

var recent_unfocused = false

func _ready():
	Network.connect("message_received", self, "_on_message_received")

remote func newline_message(new_text):
	get_node("chat/output").text += '\n ' + new_text

remote func append_message(new_text):
	get_node("chat/output").text += new_text

func _on_chat_send_pressed():
	var input = get_node("chat/input")
	if (input.text != ''):
		var msg = 'SERVER: ' + input.text
		Network.rpc("send_message", msg)
		newline_message(msg)
	input.text = ''
	input.release_focus()
	recent_unfocused = true

func _on_chat_text_entered(new_text):
	var input = get_node("chat/input")
	if (input.text != ''):
		var msg = 'SERVER: ' + new_text
		Network.rpc("send_message", msg)
		newline_message(msg)
	input.text = ''
	input.release_focus()
	recent_unfocused = true

func _on_message_received(text):
	newline_message(text)