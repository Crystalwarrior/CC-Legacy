extends Panel

func _ready():
	gamestate.connect("message_received", self, "_on_message_received")

func _on_input_text_entered(new_text):
	$input.text = ''
	rpc('newline_message', gamestate.player_name + ': ' + new_text)

sync func newline_message(new_text):
	$output.text += '\n ' + new_text

sync func append_message(new_text):
	$output.text += new_text

func _on_send_pressed():
	if ($input.text != ''):
		rpc('newline_message', gamestate.player_name + ': ' + $input.text)
	$input.text = ''

func _on_message_received(text):
	newline_message(text)