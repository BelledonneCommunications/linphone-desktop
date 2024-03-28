#version 440

//qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o roundEffect.frag.qsb roundEffect.frag

// qt_TexCoord0 E [0.0 , 1.0]
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
	mat4 qt_Matrix;
	float qt_Opacity;
// How soft the edges should be (in pixels). Higher values could be used to simulate a drop shadow. = 1.0
	float edgeSoftness;
// The radius of the corners (in pixels).
	float radius;
	// Apply a drop shadow effect. = 0.5
	float shadowSoftness;
// Drop shadow offset. = 0.5
	float shadowOffset;
	float width;
	float height;
} ubuf;
layout(binding = 1) uniform sampler2D src;

float roundedBoxSDF(vec2 position, vec2 offset, float radius) {
	return length(max(abs(position)-offset+radius,0.0))-radius;
}

void main(){
	vec2 size = vec2(ubuf.width, ubuf.height);
	vec2 center = vec2(0.5);
	// Calculate distance to edge.
	float dist = roundedBoxSDF( (qt_TexCoord0.xy - center) * size, size/2.0 - 1.0, ubuf.radius);
	float smoothedAlpha =  max(1.0 - smoothstep(-ubuf.edgeSoftness, ubuf.edgeSoftness * 2.0, dist), 0);
	// Return the resultant shape.
	vec4 tex = texture(src, qt_TexCoord0.st);
	vec4 quadColor		= mix(vec4(0.0, 0.0, 0.0, 0.0), vec4(tex.rgb, smoothedAlpha), smoothedAlpha);
	// Apply a drop shadow effect.
	vec2 shadowOffset 	 = vec2(0.0, ubuf.shadowOffset);
	float shadowDistance = roundedBoxSDF((qt_TexCoord0.xy - center) * size, size/2.0, ubuf.radius);
	float shadowAlpha 	 = 1.0 - smoothstep(-1.0, ubuf.shadowSoftness, shadowDistance);
	vec4 shadowColor 	 = vec4(0.4, 0.4, 0.4, 1.0);
	fragColor 			 = mix(quadColor, shadowColor, shadowAlpha - smoothedAlpha) * ubuf.qt_Opacity;
}
