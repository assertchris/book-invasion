shader_type canvas_item;

uniform float amount : hint_range(0, 1) = 0.0;
uniform float bandSize = 40.0;

void fragment() {
	float yFraction = fract(FRAGCOORD.y / bandSize);
	float yDistance = abs(yFraction - 0.5);
    
	if (yDistance + UV.y > amount * 2.0) {
		discard;
	}
}