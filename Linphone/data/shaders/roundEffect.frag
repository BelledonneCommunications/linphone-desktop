#version 440
layout(location = 0) in vec2 coord;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
	mat4 qt_Matrix;
	float qt_Opacity;
	float edge;
};
layout(binding = 1) uniform sampler2D src;

void main() {
	float dist = distance(coord, vec2( 0.5 ));
	float delta = fwidth(dist);
	float alpha = smoothstep( mix(clamp(edge, 0.0, 1.0), 0.0, 0.5) - delta, 0.5, dist );
	
	vec4 tex = texture(src, coord);
	fragColor = mix( tex, vec4(0.0), alpha) * qt_Opacity;
}
