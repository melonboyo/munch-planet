shader_type spatial;
render_mode diffuse_lambert_wrap;

uniform vec4 albedo : source_color;
uniform sampler2D albedo_texture : hint_default_white, filter_nearest_mipmap;
//uniform sampler2D overlay_texture : hint_default_white, filter_nearest;
uniform vec2 albedo_uv_scale = vec2(1.0);
uniform vec2 albedo_uv_offset = vec2(0.0);

uniform bool use_normal_texture = false;
uniform sampler2D normal_texture : hint_normal;
uniform float normal_depth : hint_range(0.0, 2.0) = 1.0;

uniform float roughness : hint_range(0.0, 1.0) = 0.8;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

uniform float specularity : hint_range(0.0, 1.0) = 0.3;
uniform float specular_tint : hint_range(0.0, 1.0) = 0.5;

uniform float sheen : hint_range(0.0, 1.0) = 0.5;
uniform float sheen_tint : hint_range(0.0, 1.0) = 0.5;
uniform float subsurface : hint_range(0.0, 1.0) = 0.0;

uniform float shadow_cutoff: hint_range(-2.0, 2.0) = 0.5;
uniform float shadow_cutoff_smoothness : hint_range(0.0, 1.0) = 1.0;

uniform float wobble_displacement : hint_range(0.0, 10.0) = 0.01;
uniform float wobble_frequency : hint_range(0.1, 5.0) = 2.0;
uniform int num_of_wobbles : hint_range(0, 100, 1) = 7;
uniform bool use_uv2 = true;
uniform sampler2D wobble_noise : hint_default_white;


float random (vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
	float m = 1.00000;
	float smooth_ascend = mod(TIME * (1.0/wobble_frequency), m) * float(num_of_wobbles) + 5.0;
	float int_ascend = ceil(smooth_ascend);
	vec2 uv = UV;
	if (use_uv2) {
		uv = UV2;
	}
	float rand_num = mod(int_ascend * texture(wobble_noise, uv).r * 23.0 * float(num_of_wobbles), float(num_of_wobbles));
	float rand_remapped = -1.0 + 2.0 * (rand_num / float(num_of_wobbles));
	float displacement = rand_remapped * wobble_displacement * 0.01;
	VERTEX += NORMAL * displacement;
}

void fragment() {
	vec4 albedo_tex = texture(albedo_texture, UV*albedo_uv_scale+albedo_uv_offset);
	vec4 normal_tex = texture(normal_texture, UV);
	//vec4 overlay_tex = texture(overlay_texture, UV);
	//ALBEDO = albedo.rgb * albedo_tex.rgb + (overlay_tex.rgb + vec3(-1.0));
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ROUGHNESS = roughness;
	SPECULAR = specularity;
	//METALLIC = metallic;
	if (use_normal_texture) {
		NORMAL_MAP = normal_tex.rgb;
	}
}

float fresnel(float LdotH) {
	return pow(clamp(1.0 - LdotH, 0.0, 1.0), 5.0);
}

vec3 mon2lin(vec3 color) {
	return vec3(pow(color.r, 2.2), pow(color.g, 2.2), pow(color.b, 2.2));
}

vec3 calculate_lambertian_diffuse(float NdotL, vec3 color, vec3 light_col) {
	float theta = smoothstep(0.0, 1.0, NdotL);
	vec3 diffuse_component = ((light_col * color) / PI) * theta;
	return diffuse_component;
}

float calculate_subsurface_diffuse(float LdotH, float fresnel_NdotL, float fresnel_NdotV, float NdotL, float NdotV) {
	float adjacent_fresnel = pow(LdotH, 2.0) * roughness;
	float subsurf_diffuse = mix(1.0, adjacent_fresnel, fresnel_NdotL) * mix(1.0, adjacent_fresnel, NdotV);
	float intensity_adjustment = 1.25 * (subsurf_diffuse * (1.0 / (NdotL + NdotV) - 0.5) + 0.5);
	return intensity_adjustment;
}

vec3 calculate_lambertian_specular(float NdotH, float NdotL, vec3 color, vec3 light_col) {
	float spec = pow(NdotH, 256.0 * max(0.0001, specularity));
	float theta = smoothstep(0.0, 1.0, NdotL);
	return (20.0 * metallic) * mix(color, mix(light_col, color, max(specular_tint, metallic)), specularity) * spec * theta;
}

vec3 calculate_burley_sheen(vec3 color, vec3 light, float luminance, float fresnel_LdotH) {
	vec3 tint = luminance > 0.0 ? color / luminance : light;
	vec3 color_sheen = mix(light, tint, sheen_tint);
	return 2.0 * ((fresnel_LdotH + subsurface) * color_sheen) * sheen;
}

float calculate_scattering_diffuse(float LdotH, float fresnel_NdotL, float fresnel_NdotV) {
	fresnel_NdotV = abs(fresnel_NdotV);
	fresnel_NdotL = abs(fresnel_NdotL);
	float adjacent_fresnel = 0.5 + 2.0 * pow(LdotH, 2.0) * roughness;
	return mix(1.0, adjacent_fresnel, fresnel_NdotL) * mix(1.0, adjacent_fresnel, fresnel_NdotV);
}

void light() {
	vec3 color = mon2lin(ALBEDO);
	vec3 light = mon2lin(LIGHT_COLOR);
	//vec3 color = ALBEDO;
	//vec3 light = LIGHT_COLOR;
	
	
	float lum = 0.3 * color.r + 0.6 * color.g + 0.1 * color.b;
	
	vec3 H = normalize(LIGHT + VIEW);
	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	
	float NdotH = max(dot(NORMAL, H), 0.0);
	float LdotH = max(dot(LIGHT, H), 0.0);
	
	float fresnel_NdotL = fresnel(NdotL);
	float fresnel_NdotV = fresnel(NdotV);
	float fresnel_LdotH = fresnel(LdotH);
	
	//NdotL = NdotL * 0.5 + 0.5;
	NdotL = clamp(NdotL * 0.5 + 0.5, 0.5, 1.0);
	NdotV = NdotV * 0.5 + 0.5;
	//NdotV = clamp(pow(NdotV, 0.5) * 0.8, 0.05, 1.0);
	NdotH = NdotH * 0.9 + 0.1;
	LdotH = LdotH * 0.3 + 0.6;
	
	vec3 diffuse_light = calculate_lambertian_diffuse(NdotL, color, light);
	//vec3 diffuse_light = DIFFUSE_LIGHT;

	diffuse_light *= mix(
		calculate_scattering_diffuse(LdotH, fresnel_NdotL, fresnel_NdotV),
		calculate_subsurface_diffuse(NdotH, fresnel_NdotL, fresnel_NdotV, NdotL, NdotV),
		subsurface
	);
	//
	diffuse_light *= (1.0 - metallic);
	//
	
	//diffuse_light += mix(
		//color,
		//color,
		//0.6
	//);
	diffuse_light += mix(
		calculate_burley_sheen(color, light, lum, fresnel_LdotH),
		calculate_lambertian_specular(NdotH, NdotL, color, light),
		NdotH
	);
	
	
	diffuse_light /= PI;
	diffuse_light *= LIGHT_IS_DIRECTIONAL ? clamp(smoothstep(shadow_cutoff, shadow_cutoff+shadow_cutoff_smoothness, ATTENUATION) * 0.8, 0.1, 0.8) : ATTENUATION;
	//diffuse_light *= ATTENUATION;
	
	diffuse_light = mix(diffuse_light, DIFFUSE_LIGHT, 0.1);
	
	DIFFUSE_LIGHT += diffuse_light;
	
	
	//vec3 other_diffuse_light = NdotL * ATTENUATION * LIGHT_COLOR;
	//other_diffuse_light *= LIGHT_IS_DIRECTIONAL ? clamp(pow(ATTENUATION, shadow_cutoff_smoothness) * 0.5, 0.0, 0.5) : ATTENUATION;
	//
	//DIFFUSE_LIGHT += other_diffuse_light;
}
