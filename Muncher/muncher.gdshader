shader_type spatial;

void fragment() {
	vec3 color = vec3(0.32, 0.58, 0.14);
	ALBEDO = color;
}

void light() {
    DIFFUSE_LIGHT += clamp(pow(dot(NORMAL, LIGHT), 0.1) * 0.3, 0.0, 0.3) * clamp(pow(ATTENUATION, 0.2), 0.0, 1.0) * (LIGHT_COLOR * vec3(0.9, 1.4, 0.5));
//	SPECULAR_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR;
}
