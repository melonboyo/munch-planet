shader_type canvas_item;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy+TIME*0.12;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
uniform sampler2D texture_1;
const float texture_1_size = 1024.0;
const float p_o8517_gradient_0_pos = 0.000000000;
const vec4 p_o8517_gradient_0_col = vec4(0.278320014, 0.296584994, 0.445311993, 1.000000000);
const float p_o8517_gradient_1_pos = 1.000000000;
const vec4 p_o8517_gradient_1_col = vec4(0.326157004, 0.332489997, 0.488281012, 1.000000000);
vec4 o8517_gradient_gradient_fct(float x) {
  if (x < p_o8517_gradient_0_pos) {
    return p_o8517_gradient_0_col;
  } else if (x < p_o8517_gradient_1_pos) {
    return mix(p_o8517_gradient_0_col, p_o8517_gradient_1_col, ((x-p_o8517_gradient_0_pos)/(p_o8517_gradient_1_pos-p_o8517_gradient_0_pos)));
  }
  return p_o8517_gradient_1_col;
}
const float p_o8449_width = 0.070000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec4 o8463_0 = textureLod(texture_1, (uv), 0.0);
vec3 o8449_0_false = clamp((o8463_0.rgb-vec3( clamp((0.5+0.15*sin(elapsed_time)), 0.0001, 0.9999)))/max(0.0001, p_o8449_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o8449_0_true = vec3(1.0)-o8449_0_false;vec4 o8449_0_1_rgba = vec4(o8449_0_false, o8463_0.a);
vec4 o8517_0_1_rgba = o8517_gradient_gradient_fct((dot((o8449_0_1_rgba).rgb, vec3(1.0))/3.0));

	vec4 color_tex = o8517_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	COLOR = color_tex;

}



