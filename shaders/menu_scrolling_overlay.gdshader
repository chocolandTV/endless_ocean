shader_type canvas_item;

uniform vec2 scroll_speed = vec2(-0.012, 0.0);
uniform float texture_scale = 1.6;

void fragment() {
	vec2 uv = fract(UV * texture_scale + TIME * scroll_speed);
	vec4 pattern = texture(TEXTURE, uv);
	COLOR = vec4(COLOR.rgb * pattern.rgb, COLOR.a * pattern.a);
}
