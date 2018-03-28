#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

float rand(float x, float y) { // Returns some randomish number
    return abs(fract((157.2943 + 43.499 * x + 209.63 * y) * (sin(203.11 * (x + 66.603))+ cos(50.9 * y))));
}

// Turns the scene into greyscale pointilism. Pretty basic shader
void main() {
    ivec2 texDim = textureSize(u_frame, 0);
    float r = rand(fs_UV.x * float(texDim.x), fs_UV.y * float(texDim.y));
    r = clamp(r, 0.05, 0.95); // Make sure a pixel can always be past the threshold if its light/dark enough
    vec3 color = texture(u_frame, fs_UV).xyz;
    float intensity = max(color.x, max(color.y, color.z));
    color = vec3(1.0);

    if(intensity < r) { // compare the random number to the intensity to see how likely it is that this should be dark
        color = vec3(0.0);
    }

    out_Col = vec4(color, 1.0); // pass the origial frame on to the bloom postprocess
}