shader_type canvas_item;

uniform float param;
uniform float power;

void fragment()
{
	vec4 color = texture(TEXTURE,UV);
	color.a *= pow(UV.y+param,power);
	COLOR = color;
}