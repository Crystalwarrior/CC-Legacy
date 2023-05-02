extends Control

var chara = null
onready var hairlist = $HairList

func _ready():
	hairlist.add_item("john")
	hairlist.add_item("gina")
	hairlist.add_item("looseponytail")
	hairlist.add_item("ragged")
	
	chara = $Character
	
	_on_Randomize_pressed()

func _on_Character_avatar_changed(type, value):
	match type:
		"hair_name":
			pass
		"hair_color":
			if $HairColor.color != value:
				$HairColor.color = value
		"eye_color":
			if $EyeColor.color != value:
				$EyeColor.color = value
		"shirt_color":
			if $ShirtColor.color != value:
				$ShirtColor.color = value
		"pants_color":
			if $PantsColor.color != value:
				$PantsColor.color = value
		"skin_color":
			if $SkinColor.color != value:
				$SkinColor.color = value

func _on_HairColor_color_changed(color):
	chara.hair_color = color
	get_parent().data.character.hair_color = color

func _on_EyeColor_color_changed(color):
	chara.eye_color = color
	get_parent().data.character.eye_color = color

func _on_ShirtColor_color_changed(color):
	chara.shirt_color = color
	get_parent().data.character.shirt_color = color

func _on_SkinColor_color_changed(color):
	chara.skin_color = color
	get_parent().data.character.skin_color = color

func _on_PantsColor_color_changed(color):
	chara.pants_color = color
	get_parent().data.character.pants_color = color

func _on_ItemList_item_activated(index):
	chara.hair_name = $HairList.get_item_text(index)
	get_parent().data.character.hair_name = chara.hair_name

func _on_Charedit_pressed():
	visible = not visible

func _on_Randomize_pressed():
	var color = Color()
	color = chara.random_color_generic()
	chara.shirt_color = color
	get_parent().data.character.shirt_color = color

	color = chara.random_color_hair()
	chara.hair_color = color
	get_parent().data.character.hair_color = color

	color = chara.random_color_pants()
	chara.pants_color = color
	get_parent().data.character.pants_color = color

	color = chara.random_color_eye()
	chara.eye_color = color
	get_parent().data.character.eye_color = color

	color = chara.random_color_skin()
	chara.skin_color = color
	get_parent().data.character.skin_color = color

	randomize()
	chara.hair_name = hairlist.get_item_text(randi() % hairlist.get_item_count())
	get_parent().data.character.hair_name = chara.hair_name
#	randomize()
#	self_data.character.shirt_color = Color(randi() % 2, randi() % 2, randi() % 2)
#
#	randomize()
#	self_data.character.pants_color = Color(randi() % 2, randi() % 2, randi() % 2)
#
#	randomize()
#	self_data.character.eye_color = Color(randi() % 2, randi() % 2, randi() % 2)
#
#	var hairs = ["john", "gina", "looseponytail", "ragged"] #todo: use an enum instead
#	randomize()
#	self_data.character.hair_name = hairs[randi() % hairs.size()]
#
#	randomize()
#	self_data.character.hair_color = Color(randi() % 2, randi() % 2, randi() % 2)
