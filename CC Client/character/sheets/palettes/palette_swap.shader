shader_type canvas_item;

//The palette used
uniform sampler2D palette;
//how many horizontal pixels has the palette
uniform float palette_size;
//Mask for wich color use from palette
uniform sampler2D mask;

void fragment() {
	vec4 mask_color = texture(mask,UV);
	vec4 output = texture(TEXTURE,UV);
	if(mask_color.r != 1.0)
	{
		highp float color_r = mask_color.r;
		//If an inconsistency appears between Intel and Amd/Nvidia, feel free to fix it and commit, but take this as a warning for production use
		output = texture(palette,vec2((color_r*255.0+0.5)/255.0,0.0));
	}
	COLOR.rgba = output;
}
