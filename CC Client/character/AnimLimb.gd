extends Node2D

export(StreamTexture) var base_palette = null
export(String) var current_anim = "idle"

var direction = Dirs.SOUTH

var palette_size = 0 setget _set_palette_size
var _palette_texture = null

func _ready():
	#StreamTexture doesn't have set_data method, so Change it to ImageTexture, used by random colors
	var image_texture = ImageTexture.new()
	var image = base_palette.get_data()
	image_texture.create_from_image(image,0)
	image_texture.storage = ImageTexture.STORAGE_COMPRESS_LOSSLESS
#	var palette_reference = get_node("../hud/reference")
#	palette_reference.texture = image_texture
	_palette_texture = image_texture

#Update the width of the palette
func _set_palette_size(value):
	if(palette_size != value):
		palette_size = value
		get_material().set_shader_param("palette_size",palette_size)

#Might be expensive to use this func in a loop. Recreate it outside func instead in that case.
func _set_pixel_color(x, y, color):
	var image = _palette_texture.get_data()
	image.lock()
	image.set_pixel(x,y,color)
	image.unlock()
	_palette_texture.set_data(image)
	get_material().set_shader_param("palette",_palette_texture)
	palette_size = _palette_texture.get_width()

func change_anim(anim_name, preserve = false):
	if not get_node(current_anim):
		return
	get_node(current_anim).visible = false
	var anim = get_node(current_anim).get_node("AnimationPlayer")
	var current_anim_position = null
	if anim and anim.current_animation:
		current_anim_position = anim.current_animation_position
		anim.stop()

	current_anim = anim_name
	get_node(current_anim).visible = true
	anim = get_node(current_anim).get_node("AnimationPlayer")
	if anim:
		anim.play(Dirs.dirToStr(direction))
		if preserve and current_anim_position: #Preserve animation time
			anim.advance(current_anim_position)

	get_material().set_shader_param("mask",get_node(current_anim).image_mask)

func change_anim_dir(dir):
	if not dir:
		dir = Dirs.SOUTH
	direction = dir
	var anim_name = get_node(current_anim).name
	var anim = get_node(current_anim).get_node("AnimationPlayer")
	if anim:
		var current_anim_position = anim.current_animation_position
		anim.set_current_animation(Dirs.dirToStr(dir))
		if anim.current_animation:
			anim.advance(current_anim_position)

func _on_Character_direction_changed(new_direction):
	change_anim_dir(Dirs.vectorToDir(new_direction))
