shader_type canvas_item;

const vec4 white_color = vec4(1, 1, 1, 1); 
uniform float white_multiplier: hint_range(0, 1) = 0.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	float alpha = original_color.a;
	COLOR = mix(original_color, white_color, white_multiplier * alpha);
}