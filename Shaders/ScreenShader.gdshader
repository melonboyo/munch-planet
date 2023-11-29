shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform float color_outline_scale = 2.0; // Size of color outlines
uniform float depth_outline_scale = 2.0; // Size of depth outlines
uniform float depth_threshold : hint_range(0,10) = 2.5; // Controls sensitivity to depth changes (lower values mean more outlines, but more artifacts too)
uniform float depth_multiplier = 1000.0; // Multiplier for depth values
uniform float edge_threshold : hint_range(0,1) = 0.04; // General threshold for values to be considered as edges
uniform float max_edge_alpha : hint_range(0,1) = 0.8; // Max edge alpha, lower values means edges blend more with background
uniform float edge_alpha_multiplier = 3.0; // General multiplier for edge alpha value, higher values mean harder edges

uniform vec4 edge_color : source_color = vec4(0,0,0,1.0); // Outlines color
uniform sampler2D bgTex : source_color; // BG texture

uniform bool depth_use_laplace = true; // Sets depth edges to use the laplace operator instead of sobel
uniform bool color_use_laplace = false; // Sets color edges to use the laplace operator instead of sobel
uniform bool use_bg_texture = false; // Sets shader to use render the BG behind the edges

uniform sampler2D depth_texture : source_color, hint_depth_texture, repeat_disable, filter_linear;
uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable, filter_linear;

varying mat4 CAMERA;


void vertex() {
	POSITION = vec4(VERTEX, 1.0);
	CAMERA = INV_VIEW_MATRIX;
}

float getDepthVal(sampler2D depthTex, vec2 depthUV, mat4 invProjMat) {
	float depth = texture(depthTex, depthUV).r;
	return depth;
}

void fragment() {
	float halfScaleFloor_c = floor(color_outline_scale * 0.5);
	float halfScaleCeil_c = ceil(color_outline_scale * 0.5);
	float halfScaleFloor_d = floor(depth_outline_scale * 0.5);
	float halfScaleCeil_d = ceil(depth_outline_scale * 0.5);
	vec2 texelSize = vec2(1.0/VIEWPORT_SIZE.x, 1.0/VIEWPORT_SIZE.y);
	
	vec2 bottomLeftUV_c = SCREEN_UV - vec2(texelSize.x, texelSize.y) * halfScaleFloor_c;
	vec2 topRightUV_c = SCREEN_UV + vec2(texelSize.x, texelSize.y) * halfScaleCeil_c;
	vec2 topUV_c = SCREEN_UV + vec2(0.0, texelSize.y * halfScaleCeil_c);
	vec2 bottomUV_c = SCREEN_UV + vec2(0.0, -texelSize.y * halfScaleFloor_c);
	vec2 rightUV_c = SCREEN_UV + vec2(texelSize.x * halfScaleCeil_c, 0.0);
	vec2 leftUV_c = SCREEN_UV + vec2(-texelSize.x * halfScaleFloor_c, 0.0);
	vec2 bottomRightUV_c = SCREEN_UV + vec2(texelSize.x * halfScaleCeil_c, -texelSize.y * halfScaleFloor_c);
	vec2 topLeftUV_c = SCREEN_UV + vec2(-texelSize.x * halfScaleFloor_c, texelSize.y * halfScaleCeil_c);
	vec2 centerUV_c = SCREEN_UV;
	
	vec2 bottomLeftUV_d = SCREEN_UV - vec2(texelSize.x, texelSize.y) * halfScaleFloor_d;
	vec2 topRightUV_d = SCREEN_UV + vec2(texelSize.x, texelSize.y) * halfScaleCeil_d;
	vec2 topUV_d = SCREEN_UV + vec2(0.0, texelSize.y * halfScaleCeil_d);
	vec2 bottomUV_d = SCREEN_UV + vec2(0.0, -texelSize.y * halfScaleFloor_d);
	vec2 rightUV_d = SCREEN_UV + vec2(texelSize.x * halfScaleCeil_d, 0.0);
	vec2 leftUV_d = SCREEN_UV + vec2(-texelSize.x * halfScaleFloor_d, 0.0);
	vec2 bottomRightUV_d = SCREEN_UV + vec2(texelSize.x * halfScaleCeil_d, -texelSize.y * halfScaleFloor_d);
	vec2 topLeftUV_d = SCREEN_UV + vec2(-texelSize.x * halfScaleFloor_d, texelSize.y * halfScaleCeil_d);
	vec2 centerUV_d = SCREEN_UV;
	
	float d0 = getDepthVal(depth_texture, topLeftUV_d, INV_PROJECTION_MATRIX);
	float d1 = getDepthVal(depth_texture, topUV_d, INV_PROJECTION_MATRIX);
	float d2 = getDepthVal(depth_texture, topRightUV_d, INV_PROJECTION_MATRIX);
	float d3 = getDepthVal(depth_texture, leftUV_d, INV_PROJECTION_MATRIX);
	float d4 = getDepthVal(depth_texture, centerUV_d, INV_PROJECTION_MATRIX);
	float d5 = getDepthVal(depth_texture, rightUV_d, INV_PROJECTION_MATRIX);
	float d6 = getDepthVal(depth_texture, bottomLeftUV_d, INV_PROJECTION_MATRIX);
	float d7 = getDepthVal(depth_texture, bottomUV_d, INV_PROJECTION_MATRIX);
	float d8 = getDepthVal(depth_texture, bottomRightUV_d, INV_PROJECTION_MATRIX);
	
	float edgeDepth = 0.0;
	if (depth_use_laplace) {
		 edgeDepth = (8.0 * d4 - (d0+d1+d2+d3+d5+d6+d7+d8)) * depth_multiplier;
	}
	else {
		float d_sobel_edge_h = (d2 + (2.0*d5) + d8 - (d0 + (2.0*d3) + d6)) / 4.0;
  		float d_sobel_edge_v = (d0 + (2.0*d1) + d2 - (d6 + (2.0*d7) + d8)) / 4.0;
		edgeDepth = sqrt((d_sobel_edge_h * d_sobel_edge_h) + (d_sobel_edge_v * d_sobel_edge_v)) * depth_multiplier;
	}
	
	
	float depthThreshold = depth_threshold * d0;
	edgeDepth = smoothstep(depthThreshold-depthThreshold/5.0, depthThreshold, edgeDepth);
	
	float edgeVal = edgeDepth;
	
	vec4 n0 = texture(screen_texture, topLeftUV_c);
	vec4 n1 = texture(screen_texture, topUV_c);
	vec4 n2 = texture(screen_texture, topRightUV_c);
	vec4 n3 = texture(screen_texture, leftUV_c);
	vec4 n4 = texture(screen_texture, centerUV_c);
	vec4 n5 = texture(screen_texture, rightUV_c);
	vec4 n6 = texture(screen_texture, bottomLeftUV_c);
	vec4 n7 = texture(screen_texture, bottomUV_c);
	vec4 n8 = texture(screen_texture, bottomRightUV_c);
	
	float color_edge;
	
	if (color_use_laplace) {
		vec4 laplace_edge = (8.0 * n4 - (n0+n1+n2+n3+n5+n6+n7+n8));
		color_edge = laplace_edge.r;
		color_edge += laplace_edge.g;
    	color_edge +=  laplace_edge.b;
    	color_edge /= 3.0;
	}
	else {
		vec4 sobel_edge_h = (n2 + (2.0*n5) + n8 - (n0 + (2.0*n3) + n6)) / 4.0;
		vec4 sobel_edge_v = (n0 + (2.0*n1) + n2 - (n6 + (2.0*n7) + n8)) / 4.0;
		vec4 sobel = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));
		color_edge = sobel.r;
		color_edge += sobel.g;
		color_edge +=  sobel.b;
		color_edge /= 3.0;
	}
	
	edgeVal = max(edgeVal, color_edge);
	
	if (edgeVal > edge_threshold) {
		if (use_bg_texture) {
			ALBEDO = edge_color.rgb * texture(bgTex, SCREEN_UV).rgb;
		}
		else {
			ALBEDO = edge_color.rgb;
			ALPHA = min(max_edge_alpha,edgeVal * edge_alpha_multiplier);
		}
		
	}
	else {
		if (use_bg_texture) {
			ALBEDO = texture(bgTex, SCREEN_UV).rgb;
		}
		else {
			ALPHA = 0.0;
		}
	}
}

//void fragment() {
//	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
//
//	float depth = texture(depth_texture, SCREEN_UV).x;
//	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
//	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//	view.xyz /= view.w;
//	float linear_depth = -view.z;
//
//	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//	vec3 world_position = world.xyz / world.w;
//
//	ALBEDO = screen_color;
//}
