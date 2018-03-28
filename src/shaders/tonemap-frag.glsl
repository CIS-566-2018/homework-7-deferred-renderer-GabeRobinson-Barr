#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;


void main() {
	// TODO: proper tonemapping
	// This shader just clamps the input color to the range [0, 1]
	// and performs basic gamma correction.
	// It does not properly handle HDR values; you must implement that.

	vec3 color = texture(u_frame, fs_UV).xyz;
	//color = min(vec3(1.0), color); // Unneeded after hdr tone mapping

	// Tone Mapping
	color *= 4.0; // Using an exposure value of 4 because 16 is way too high
	
	vec3 x = max(vec3(0.0), color - 0.004);
	color = (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);

	// gamma correction
	//color = pow(color, vec3(1.0 / 2.2)); // Dont need this for this version of tone mapping
	color = clamp(color, 0.0, 1.0);

	out_Col = vec4(color, 1.0);
}
