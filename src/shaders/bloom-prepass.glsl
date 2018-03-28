#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 fragColor[2]; // 2 outputs, the bloom blur, and a copy of the original frame

uniform sampler2D u_frame;
uniform float u_Time;

// Very basic prep for bloom. Passes only the colors that are high enough for the bloom effect
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;

    float intensity = length(color);
    if (intensity < 1.0) { // keep the colors with intensity higher than 1
        color = vec3(0.0);
    }

	fragColor[0] = vec4(color, 1.0); // Colors with intensity >= 1.0
    fragColor[1] = texture(u_frame, fs_UV); // pass the origial frame on to the bloom postprocess
}