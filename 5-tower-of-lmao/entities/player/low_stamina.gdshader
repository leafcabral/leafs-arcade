shader_type canvas_item;

uniform bool activated = false;
uniform vec4 color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float mix_amount: hint_range(0.0, 1.0, 0.01) = 0.5;


void fragment() {
	if (activated) {
		if (COLOR.a > 0.0) {
			COLOR = mix(COLOR, color, mix_amount);
		}
	}
}
