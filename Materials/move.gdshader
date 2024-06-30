
shader_type spatial;
uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;


void vertex() {
    VERTEX.x += sin(UV.y * TIME) * 1.0;
	
	
    //VERTEX.x += sin(VERTEX.x * 32.0 * 0.9123 + TIME * sway_speed * 1.3123) * strength * cos(VERTEX.x);
}

void fragment() {

	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
