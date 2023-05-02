extends MenuButton

var popup

func _ready():
	popup = get_popup()
	popup.add_item("Tag")
	popup.add_item("KotH")
	popup.add_item("Murder")
	popup.connect("id_pressed", self, "_on_id_pressed")

func _on_id_pressed(ID):
	print(popup.get_item_text(ID), " pressed")
	text = popup.get_item_text(ID)
	$"/root/Game/ModeManager".current = text